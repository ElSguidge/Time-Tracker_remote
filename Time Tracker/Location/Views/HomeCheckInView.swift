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
            ZStack {
                Color(uiColor: .gray).edgesIgnoringSafeArea(.all)
                VStack {
                    Text("\(userProfile.fullName)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 30)
                    
                    if authViewModel.userSession != nil {
                        
                        HStack {
                            Image(systemName: userProfile.checkedIn.isCheckedIn ? "checkmark.circle.fill" : "x.circle.fill")
                                .foregroundColor(userProfile.checkedIn.isCheckedIn ? .green : .gray)
                            Text("Last checked into:")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            Text("\(userProfile.checkedIn.projectName)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        HStack {
                            //                            Image(systemName: "house.fill")
                            //                                .foregroundColor(.white)
                            Text("Address:")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            Text("\(userProfile.checkedIn.projectAddress)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        HStack {
                            
                            Text("Job number:")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            Text("\(userProfile.checkedIn.projectJobNumber)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        HStack {
                            
                            Text("Timestamp:")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                            Text("\(userProfile.checkedIn.date)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
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
                    else {
                        Text("Not logged in.")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                    }
                }
            }
        }
    }
