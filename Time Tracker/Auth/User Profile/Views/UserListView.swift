//
//  UserListView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI

struct UserListView: View {
    
    var userProfiles: [UserProfile]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("My team")) {
                    List {
                        ForEach(userProfiles, id: \.self) { profile in
                            NavigationLink {
                                UserDetailView(user: profile)
                            } label: {
                                HStack {
                                    Image(systemName: profile.isLoggedIn ? "checkmark.circle.fill" : "x.circle.fill")
                                        .foregroundColor(profile.isLoggedIn ? .green : .gray)
                                        .padding(5)
                                    Text(profile.fullName)
                                }
                                
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("My Team")
        }
    }
}

