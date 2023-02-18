//
//  MapViewModel.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation
import MapKit

enum AlertState {
    case success, exists, error, none
}

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331517, longitude: -121.891054), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    @Published var userProfiles: [UserProfile] = []
    @Published var userProfile: UserProfile = UserProfile(uid: "", fullName: "", email: "", isLoggedIn: false, location: GeoPoint(latitude: 0.0, longitude: 0.0), checkedIn: CheckIn())
    @Published var alertState: AlertState = .none

    let profileRepository = UserProfileRepository()
    
    let authViewModel = AuthViewModel.shared
    
    let user = AuthenticationService.shared
    
    var locationManager: CLLocationManager?
    
    var projects: [Project] = []
    
    let db = Firestore.firestore()
    

    
    func createProject(name: String, location: CLLocationCoordinate2D, address: String, jobNumber: String) {
        guard let _ = self.authViewModel.userSession?.uid else { return }

        let projectRef = db.collection("projects")
        projectRef.whereField("name", isEqualTo: name).whereField("jobNumber", isEqualTo: jobNumber).getDocuments { (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                self.alertState = .error
                return
            }

            if snapshot?.documents.count ?? 0 > 0 {
                // project already exists, show an error message or return without creating a new project
                print("Project with the same name and job number already exists")
                self.alertState = .exists
                return
            }

            let project = Project(name: name, location: GeoPoint(latitude: location.latitude, longitude: location.longitude), address: address, jobNumber: jobNumber)
            let projectRef = self.db.collection("projects").document()
            projectRef.setData(project.toDict()) { (error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                print("Project created")
                self.fetchProjects()
                self.alertState = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if self.userProfile.checkedIn.isCheckedIn == false {
                        self.checkInToProject(currentLocation: self.locationManager?.location)
                    }
                }
            }
        }
    }

//    func createProject(name: String, location: CLLocationCoordinate2D, address: String, jobNumber: String) {
//        guard let _ = self.authViewModel.userSession?.uid else { return }
//        let project = Project(name: name, location: GeoPoint(latitude: location.latitude, longitude: location.longitude), address: address, jobNumber: jobNumber)
//        let projectRef = db.collection("projects").document()
//        projectRef.setData(project.toDict()) { (error) in
//            if error != nil {
//                print(error?.localizedDescription as Any)
//                return
//            }
//            print("Project created")
//            self.fetchProjects()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                if self.userProfile.checkedIn.isCheckedIn == false {
//                    self.checkInToProject(currentLocation: self.locationManager?.location)
//                }
//            }
//        }
//    }
    
    func fetchProjects() {
        db.collection("projects").getDocuments{ (snapshot, error) in
            if error != nil {
                print((error?.localizedDescription as Any))
                return
            }
            for document in snapshot!.documents {
                let data = document.data()
                let project = Project(name: data["name"] as! String, location: data["location"] as! GeoPoint, address: data["address"] as! String, jobNumber: data["jobNumber"] as! String)
                self.projects.append(project)
            }
        }
    }
    
    func checkIfLocationServicesIsEnabled() {
        


        if CLLocationManager.locationServicesEnabled() {
            
                self.locationManager = CLLocationManager()
                self.locationManager!.delegate = self
                self.locationManager?.startUpdatingLocation()
                
                self.fetchProjects()
                
                self.profileRepository.fetchAllProfiles { (profiles, error) in
                    if let error = error {
                        print("Error fetching user profiles: \(error)")
                        return
                    }
                    if let profiles = profiles {
                        self.userProfiles = profiles
                        if let uid = self.user.user?.uid {
                            if let userProfile = profiles.first(where: { $0.uid == uid }) {
                                self.userProfile = userProfile
                            } else {
                                print("No profile found for user with UID: \(uid)")
                            }
                        } else {
                            print("No UID found for user")
                        }
                    }
                }

        }
    }
    
    private func checkLocationAuthorization() {
        
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted")
        case .denied:
            
            let locationAlert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services in settings to use this feature", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                let notificationSettingsURL = URL(string: UIApplication.openSettingsURLString)!.appendingPathComponent("location")
                UIApplication.shared.open(notificationSettingsURL, options: [:], completionHandler: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            locationAlert.addAction(okAction)
            locationAlert.addAction(cancelAction)
            
            let windowScene = UIApplication.shared.connectedScenes.first as! UIWindowScene
            windowScene.windows.first!.rootViewController?.present(locationAlert, animated: true, completion: nil)
            
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            self.checkInToProject(currentLocation: self.locationManager?.location)
        @unknown default:
            break
        }
    }
    
    private func checkInToProject(currentLocation: CLLocation?) {
        
        guard let currentLocation = currentLocation else { return }
        guard let _ = authViewModel.userSession else { return }

        let currentLocationCoordinate = currentLocation.coordinate
        let center = GeoPoint(latitude: currentLocationCoordinate.latitude, longitude: currentLocationCoordinate.longitude)
        let radius = 1000.0 // 1km
        
        let query = db.collection("projects").whereField("location", isGreaterThanOrEqualTo: GeoPoint(latitude: center.latitude - 0.1, longitude: center.longitude - 0.1))
            .whereField("location", isLessThanOrEqualTo: GeoPoint(latitude: center.latitude + 0.1, longitude: center.longitude + 0.1))
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        do {
                            let project = try document.data(as: Project.self)
                            // check if the project is within the radius
                            let projectLocation = CLLocation(latitude: project.location.latitude, longitude: project.location.longitude)
                            let distance = currentLocation.distance(from: projectLocation)
                            if distance <= radius {
                                // project is within the radius, show alert to check in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        self.showCheckInAlert(project: project)
                                }
                                break
                            }
                        } catch {
                            print("Error converting document data to Project: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    func showCheckInAlert(project: Project) {
        
        if userProfile.isLoggedIn != false && userProfile.checkedIn.isCheckedIn == false {
            let alert = UIAlertController(title: "Check in to project", message: "Do you want to check in to project \(project.name)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Check in", style: .default, handler: { action in
//                 check in to project
                let checkIntoProjectView = CheckIntoProjectView(userProfile: self.userProfile, projectClass: project.toProjectClass())
                let hostingController = UIHostingController(rootView: checkIntoProjectView)
                UIApplication.shared.keyWindow?.rootViewController?.present(hostingController, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let uid = self.user.user?.uid else {return}
    
        let last = locations.last
        
            DispatchQueue.main.async {
                self.profileRepository.addCoordinatesToProfile(last: last!, userId: uid)

                self.db.collection("locations").document("coordinate").setData(["updates" : [uid : GeoPoint(latitude: (last?.coordinate.latitude)!, longitude: (last?.coordinate.longitude)!)]],merge: true) { (err) in
                    
                    if err != nil{
                        
                        print((err?.localizedDescription)!)
                        return
                    }
                
            }
        }
    }
}


