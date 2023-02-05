//
//  CheckInView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 27/1/2023.
//

import SwiftUI
import FirebaseFirestore

struct HomeCheckInView: View {
    @ObservedObject var authViewModel = AuthViewModel()
    var userProfile: UserProfile
        
        var body: some View {
            
            NavigationStack {
                Form {
                    Section {
                        HStack(spacing: 40) {
                            Text("Name:")
                                .fontWeight(.semibold)
                            Text("\(userProfile.fullName)")
                        }
                        HStack(spacing: 40) {
                            Text("Current status:")
                                .fontWeight(.semibold)
                            HStack {
                                Image(systemName: userProfile.checkedIn.isCheckedIn ? "checkmark.circle.fill" : "x.circle.fill")
                                    .foregroundColor(userProfile.checkedIn.isCheckedIn ? .green : .gray)
                                Text(userProfile.checkedIn.isCheckedIn ? "Checked in" : "Not checked in")
                            }
                        }
                        HStack(spacing: 40) {
                            Text("Last checked in at:")
                                .fontWeight(.semibold)
                            Text(userProfile.checkedIn.projectName)
                        }
                        HStack(spacing: 40) {
                            Text("Address:")
                                .fontWeight(.semibold)
                            Text(userProfile.checkedIn.projectAddress)
                        }
                        HStack(spacing: 40) {
                            Text("Job number:")
                                .fontWeight(.semibold)
                            Text(userProfile.checkedIn.projectJobNumber)
                        }
                        HStack(spacing: 40) {
                            Text("Date:")
                                .fontWeight(.semibold)
                            Text("\(userProfile.checkedIn.date)")
                        }
                    }
                }
                .navigationTitle("My status")
                
                if userProfile.checkedIn.isCheckedIn {
                        Button("Check out") {
                            UserProfileRepository().checkOut(userId: authViewModel.userSession!.uid)
                        }
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                }
            }
        }
    }
