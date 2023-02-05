//
//  UserDetailView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI
import CoreLocation

struct UserDetailView: View {
    
    var user: UserProfile
    
    @State private var currentLocationAddress: String = "Loading..."
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 40) {
                        Text("Name:")
                            .fontWeight(.semibold)
                        Text("\(user.fullName)")
                    }
                    HStack(spacing: 40) {
                        Text("Email:")
                            .fontWeight(.semibold)
                        Text(user.email)
                    }
                    HStack(spacing: 40) {
                        Text("Log in status:")
                            .fontWeight(.semibold)
                        Image(systemName: user.isLoggedIn ? "checkmark.circle.fill" : "x.circle.fill")
                            .foregroundColor(user.isLoggedIn ? .green : .gray)
                    }
                    HStack(spacing: 40) {
                        Text("Check in status:")
                            .fontWeight(.semibold)
                        Image(systemName: user.checkedIn.isCheckedIn ? "checkmark.circle.fill" : "x.circle.fill")
                            .foregroundColor(user.checkedIn.isCheckedIn ? .green : .gray)
                    }
                    HStack(spacing: 40) {
                        Text("Last checked in project:")
                            .fontWeight(.semibold)
                        Text("\(user.checkedIn.projectName)")
                    }
                    HStack(spacing: 40) {
                        Text("Last checked in project number:")
                            .fontWeight(.semibold)
                        Text("\(user.checkedIn.projectJobNumber)")
                    }
                    HStack(spacing: 40) {
                        Text("Last check in address:")
                            .fontWeight(.semibold)
                        Text(user.checkedIn.projectAddress)
                    }
                    HStack(spacing: 40) {
                        Text("Date last checked in:")
                            .fontWeight(.semibold)
                        Text("\(user.checkedIn.date)")
                    }
                    HStack(spacing: 40) {
                        Text("Last logged location:")
                            .fontWeight(.semibold)
                        Text("\(currentLocationAddress)")
                    }
                }
            }
            .navigationTitle("\(user.fullName)")
        }
        .onAppear {
            self.getAddressFromLatLon(latitude: user.location.latitude, longitude: user.location.longitude) { (address) in
                self.currentLocationAddress = address ?? "Unable to retrieve address"
            }
        }
    }
    
    func getAddressFromLatLon(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (String?) -> ()) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Reverse geocode failed with error: \(error)")
                completion(nil)
                return
            }
            
            if let placemarks = placemarks, let placemark = placemarks.first {
                var addressString = ""
                
                if let subThoroughfare = placemark.subThoroughfare {
                                addressString += subThoroughfare + ", "
                            }
                
                if let thoroughfare = placemark.thoroughfare {
                    addressString += thoroughfare + ", "
                }

                if let locality = placemark.locality {
                    addressString += locality + ", "
                }

                if let postalCode = placemark.postalCode {
                    addressString += postalCode + " "
                }
                
                completion(addressString)
            } else {
                completion(nil)
            }
        }
    }

}

