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

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331517, longitude: -121.891054), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    @Published var userProfiles: [UserProfile] = []
    @Published var currentProject: Project? = nil
    @Published var alreadyCheckedIn: Bool = false
    
    let profileRepository = UserProfileRepository()
    
    let authViewModel = AuthViewModel.shared
    
    var locationManager: CLLocationManager?
    
    let db = Firestore.firestore()
    
    func createProject(name: String, location: CLLocationCoordinate2D, address: String, jobNumber: String) {
        guard let _ = self.authViewModel.userSession?.uid else { return }
        let project = Project(name: name, location: GeoPoint(latitude: location.latitude, longitude: location.longitude), address: address, jobNumber: jobNumber)
        let projectRef = db.collection("projects").document()
        projectRef.setData(project.toDict()) { (error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                return
            }
            print("Project created")
        }
    }

    
    func checkIfLocationServicesIsEnabled() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            profileRepository.fetchAllProfiles { (profiles, error) in
                if let error = error {
                    print("Error fetching user profiles: \(error)")
                    return
                }
                if let profiles = profiles {
                    self.userProfiles = profiles
                }
            }
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager?.startUpdatingLocation()
        } else {
            
            let locationAlert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services in settings to use this feature", preferredStyle: .alert)
            locationAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(locationAlert, animated: true, completion: nil)
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
            print("You have denied.....")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
            
        @unknown default:
            break
        }
    }
    
    private func checkInToProject(currentLocation: CLLocation?) {
        
        guard let currentLocation = currentLocation else { return }
        
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
                                self.showCheckInAlert(project: project)
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
            let alert = UIAlertController(title: "Check in to project", message: "Do you want to check in to project \(project.name)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Check in", style: .default, handler: { action in
                // check in to project
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            
            checkLocationAuthorization()
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
            guard let currentLocation = locations.last else { return }
            guard let uid = self.authViewModel.userSession?.uid else { return }
            
            
            let last = locations.last
            
            self.profileRepository.addCoordinatesToProfile(last: last!, userId: uid)
            
            db.collection("locations").document("coordinate").setData(["updates" : [uid : GeoPoint(latitude: (last?.coordinate.latitude)!, longitude: (last?.coordinate.longitude)!)]],merge: true) { (err) in
                
                if err != nil{
                    
                    print((err?.localizedDescription)!)
                    return
                }
            }
            let userRef = db.collection("users").document(uid)
            userRef.getDocument { (document, error) in
                if let error = error {
                    print("Error getting user document: \(error)")
                    return
                }
                guard let document = document,
                      let data = document.data(),
                      let checkedInProjectId = data["checkedInProjectId"] as? String else {
                    return
                }
                if !checkedInProjectId.isEmpty {
                    // user has already checked in, do not prompt again
                    return
                }
                
                // query projects collection to check if user's current location is within a certain radius of any existing projects
                let projectsRef = self.db.collection("projects")
                projectsRef.getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error getting projects: \(error)")
                        return
                    }
                    for document in snapshot!.documents {
                        let data = document.data()
                        let projectLocation = data["location"] as? GeoPoint
                        let projectId = document.documentID
                        
                        // calculate distance between user's current location and project location
                        let projectCoordinate = CLLocation(latitude: projectLocation!.latitude, longitude: projectLocation!.longitude)
                        let distanceInMeters = currentLocation.distance(from: projectCoordinate)
                        
                        if distanceInMeters <= 50 {
                            // show alert to check in to project
                            let alert = UIAlertController(title: "Check in to project?", message: "You are within 50 meters of a project. Would you like to check in?", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Check in", style: .default, handler: { _ in
                                // update user's document with checked in project id
                                userRef.updateData(["checkedInProjectId": projectId]) { (error) in
                                    if let error = error {
                                        print("Error updating user document: \(error)")
                                        return
                                    }
                                }
                            }))
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                            return
                        }
                    }
                }
            }
        }
}


