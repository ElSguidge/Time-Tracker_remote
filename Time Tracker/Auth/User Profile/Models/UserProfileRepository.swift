//
//  UserProfileRepository.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import MapKit

struct UserProfile: Codable, Hashable {
    @DocumentID var id: String?
//    var id = UUID()
    var uid: String
    var fullName: String
    var email: String
    var isLoggedIn: Bool
    var location: GeoPoint
    var checkedIn: CheckIn
}

struct CheckIn: Codable, Hashable, Equatable {
    
    var isCheckedIn: Bool
    var projectName: String
    var projectLocation: GeoPoint
    var projectAddress: String
    var projectJobNumber: String
    var date: Date
    
    init(isCheckedIn: Bool=false, projectName: String = "", projectLocation: GeoPoint=GeoPoint(latitude: 0.0, longitude: 0.0), projectAddress: String="", projectJobNumber: String="", date: Date=Date()) {
        self.isCheckedIn = isCheckedIn
        self.projectName = projectName
        self.projectLocation = projectLocation
        self.projectAddress = projectAddress
        self.projectJobNumber = projectJobNumber
        self.date = date
    }

}

extension CheckIn {
    func toDict() -> [String: Any] {
        return [
            "isCheckedIn": self.isCheckedIn,
            "projectName": self.projectName,
            "projectLocation": self.projectLocation,
            "projectAddress": self.projectAddress,
            "projectJobNumber": self.projectJobNumber,
            "date": self.date]
    }
}


class UserProfileRepository: ObservableObject {
    
    private var db = Firestore.firestore()
    @Published var data: [String: GeoPoint] = [:]
    @Published var isLoggedIn: Bool = false
    
    
    func createProfile(profile: UserProfile, completion: @escaping (_ profile: UserProfile?, _ error: Error?) -> Void) {
        do {
            let _ = try db.collection("profiles").document(profile.uid).setData(from: profile)
            completion(profile, nil)
        }
        catch let error {
            print("Error in writing profile to Firestore: \(error)")
            completion(nil, error)
        }
    }
    func addCoordinatesToProfile(last: CLLocation, userId: String) {
        db.collection("profiles").whereField("uid", isEqualTo: userId).getDocuments { result, error in
            if error == nil {
                for document in result!.documents {
                    document.reference.setData(["location": GeoPoint(latitude: (last.coordinate.latitude), longitude: (last.coordinate.longitude))], merge: true)
                }
            }
        }
    }
    
    func isCheckedIn(checkIn: CheckIn, userId: String) {
        db.collection("profiles").whereField("uid", isEqualTo: userId).getDocuments { result, error in
            if error == nil {
                for document in result!.documents {
                    let data: [String: Any] = ["checkedIn": checkIn.toDict()]
                    document.reference.setData(data, merge: true)
                }
            }
        }
    }
        
    func isLoggedIn(userId: String) {
        db.collection("profiles").whereField("uid", isEqualTo: userId).getDocuments { result, error in
            if error == nil {
                for document in result!.documents {
                    document.reference.setData(["isLoggedIn": true], merge: true)
                }
            }
        }
    }
    
    func isLoggedOut(userId: String, completion: @escaping (_ success: Bool) -> Void) {
        db.collection("profiles").whereField("uid", isEqualTo: userId).getDocuments { result, error in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(false)
                return
            }
            
            guard let documents = result?.documents, !documents.isEmpty else {
                print("No documents found")
                completion(false)
                return
            }
            
            let document = documents[0]
            document.reference.updateData(["isLoggedIn": false, "checkedIn.isCheckedIn": false]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                    completion(false)
                    return
                }
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["initial_notification", "renotification"])
                print("Document successfully updated")
                completion(true)
            }
        }
    }
    
    func fetchProfile(userId: String, completion: @escaping (_ profile: UserProfile?, _ error: Error?) -> Void) {
        let profileRef = db.collection("profiles").document(userId)
        profileRef.addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {
                completion(nil, nil)
                return
            }
            let profile = try? snapshot.data(as: UserProfile.self)
            completion(profile, nil)
        }
    }
    
    func fetchAllProfiles(completion: @escaping (_ profiles: [UserProfile]?, _ error: Error?) -> Void) {
        db.collection("profiles").addSnapshotListener { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let snapshot = snapshot else {
                completion(nil, nil)
                return
            }
            
            let profiles = snapshot.documents.compactMap { (document) -> UserProfile? in
                return try? document.data(as: UserProfile.self)
            }
            completion(profiles, nil)
        }
    }
    
}

