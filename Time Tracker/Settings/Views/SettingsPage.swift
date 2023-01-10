//
//  SettingsPage.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct SettingsPage: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var authenticationService: AuthenticationService
    
    var body: some View {
        NavigationStack {
            Text("Settings Page")
            
            Button(action: {
                signOutUser()
            }) {
                Text("Sign Out")
                    .bold()
                    .frame(width: 360, height: 50)
                    .background(.blue)
                    .background(.thinMaterial)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }
            
        }
    }
    func signOutUser() {
        
        authenticationService.signOut()
        
        withAnimation {
            viewRouter.currentPage = .loginPage
        }
        
    }
}

struct SettingsPage_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
    }
}
