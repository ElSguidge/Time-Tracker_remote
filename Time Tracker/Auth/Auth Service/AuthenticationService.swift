//
//  AuthenticationService.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation
import MapKit

enum AuthenticationState {
    case unauthenticated
    case authenticating
    case authenticated
}

class AuthenticationService: ObservableObject {
    // MARK: - Output
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorMessage: String = ""
    @Published var user: User?
    @Published var profile: UserProfile?
    @Published var users: [User] = []
    private var profileRepository = UserProfileRepository()
    
    
    init() {
        registerAuthStateListener()
        registerNotificationDelegate()
    }
    
    @MainActor
    func signIn(withEmail email: String, password: String) async -> Bool {
        authenticationState = .authenticating
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            profileRepository.isLoggedIn(userId: user?.uid ?? "unknown")
            
            NotificationDelegate.shared.checkNotificationPermission { granted in
                 if granted {
                     NotificationDelegate.shared.scheduleInitialNotification()
                 } else {
                     NotificationDelegate.shared.showNotificationPermissionAlert()
                 }
             }
            return true
        }
        catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                authenticationState = .unauthenticated
            }
            print(error)
            return false
        }
    }
    @MainActor
    func signUp(withEmail email: String, password: String, fullName: String) async -> Bool {
        authenticationState = .authenticating
        
        do {
            
            try await Auth.auth().createUser(withEmail: email, password: password)
            let userProfile = UserProfile(uid: user?.uid ?? "unknown", fullName: fullName, email: email, isLoggedIn: true, location: GeoPoint(latitude: 0, longitude: 0), checkedIn: CheckIn(isCheckedIn: false, project: Project(name: "", location: GeoPoint(latitude: 0, longitude: 0), address: "", jobNumber: ""), date: Date()))
            profileRepository.createProfile(profile: userProfile) { (profile, error) in
                
                if let error = error {
                    print("Error while creating the users profile: \(error)")
                    return
                }
                DispatchQueue.main.async {
                    self.profile = profile
                }
            }
            NotificationDelegate.shared.checkNotificationPermission { granted in
                 if granted {
                     NotificationDelegate.shared.scheduleInitialNotification()
                 } else {
                     NotificationDelegate.shared.showNotificationPermissionAlert()
                 }
             }
             return true
            
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                authenticationState = .unauthenticated
            }
            print(error)
            return false
        }
    }
    
    func signOut() {
        profileRepository.isLoggedOut(userId: user?.uid ?? "unknown") { success in
            if success {
                do {
                    try Auth.auth().signOut()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    private func registerAuthStateListener() {
        if handle == nil {
            handle = Auth.auth().addStateDidChangeListener { auth, user in
                Task {
                    await MainActor.run {
                        self.user = user
                        
                        if user != nil {
                            
                            self.authenticationState = .authenticated
                        }
                        else {
                            self.authenticationState = .unauthenticated
                            
                            DispatchQueue.main.async {
                            ViewRouter().currentPage = .loginPage
                            }
                            print("User signed out.")
                        }
                    }
                }
            }
        }
    }
}
