//
//  RegisterPage.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct RegisterPage: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var authenticationService: AuthenticationService
    @StateObject var regViewModel = RegisterViewModel()
    @Binding var showSignUpForm: Bool
    var focus: FocusState<LoginPage.FocusableField?>.Binding
    
    private func createUserWithEmailPassword() {
        
        Task {
            if await regViewModel.createUserWithEmailPassword() == true {
                DispatchQueue.main.async {
                    withAnimation {
                        viewRouter.currentPage = .homePage
                    }
                }
            }
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: "at")
            TextField("Email", text: $regViewModel.email)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused(focus, equals: .email)
        }
        .padding(.vertical, 6)
        .background(Divider(), alignment: .bottom)
        .padding(.bottom, 4)
        
        HStack {
            Image(systemName: "lock")
            SecureField("Password", text: $regViewModel.password)
                .focused(focus, equals: .password)
        }
        .padding(.vertical, 6)
        .background(Divider(), alignment: .bottom)
        .padding(.bottom, 8)
        HStack {
            Image(systemName: "person")
            TextField("Full Name", text: $regViewModel.fullName)
                .disableAutocorrection(true)
                .focused(focus, equals: .fullname)
                .submitLabel(.go)
                .onSubmit {
                    createUserWithEmailPassword()
                }
        }
        .padding(.vertical, 6)
        .background(Divider(), alignment: .bottom)
        .padding(.bottom, 4)
        
        if !regViewModel.errorMessage.isEmpty {
            VStack {
                Text(regViewModel.errorMessage)
                    .foregroundColor(Color(UIColor.systemRed))
            }
        }
        
        Button(action: createUserWithEmailPassword) {
            if regViewModel.authenticationState != .authenticating {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
            }
            
            else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
            }
        }
        .disabled(!regViewModel.isValid)
        .frame(maxWidth: .infinity)
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .onAppear {
            regViewModel.connect(authenticationService: authenticationService)

        }
    }
}



