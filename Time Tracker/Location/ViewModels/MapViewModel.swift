//
//  MapViewModel.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import CoreLocation
import MapKit

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.331517, longitude: -121.891054), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    @Published var userProfiles: [UserProfile] = []
    
    let profileRepository = UserProfileRepository()
    
    let authViewModel = AuthViewModel.shared
    
    var locationManager: CLLocationManager?
    
    var annotations: [MKAnnotation] = []
    
    
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
            print("Show an alert")
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
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let uid = self.authViewModel.userSession?.uid else { return }
        
        
        let last = locations.last
        
        self.profileRepository.addCoordinatesToProfile(last: last!, userId: uid)
        
        Firestore.firestore().collection("locations").document("coordinate").setData(["updates" : [uid : GeoPoint(latitude: (last?.coordinate.latitude)!, longitude: (last?.coordinate.longitude)!)]],merge: true) { (err) in
            
            
            if err != nil{
                
                print((err?.localizedDescription)!)
                return
            }
        }
    }
}
