//
//  SignUpView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 7/2/2023.
//

import SwiftUI
import RiveRuntime

struct SignUpView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var authenticationService: AuthenticationService
    @StateObject var regViewModel = RegisterViewModel()
    @Binding var showSignUp: Bool

    var focus: FocusState<SignInView.FocusableField?>.Binding
    
    private func createUserWithEmailPassword() {
        if regViewModel.fullName != "" {
            Task {
                if await regViewModel.createUserWithEmailPassword() == true {
                    DispatchQueue.main.async {
                        withAnimation {
                            viewRouter.currentPage = .homePage
                        }
                    }
                }
            }
        } else {
            regViewModel.errorMessage = "Please enter your full name to complete registration."
        }
    }
        var body: some View {
            VStack(spacing: 24) {
                Text("Sign up")
                    .customFont(.largeTitle)
                VStack(alignment: .leading) {
                    Text("Email")
                        .customFont(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("", text: $regViewModel.email)
                        .customTextField(image: Image(systemName: "at"))
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused(focus, equals: .email)
                }
                VStack(alignment: .leading) {
                    Text("Password")
                        .customFont(.subheadline)
                        .foregroundColor(.secondary)
                    SecureField("", text: $regViewModel.password)
                        .customTextField(image: Image(systemName: "lock"))
                        .focused(focus, equals: .password)
                }
                VStack(alignment: .leading) {
                    Text("Full name")
                        .customFont(.subheadline)
                        .foregroundColor(.secondary)
                    SecureField("", text: $regViewModel.fullName)
                        .customTextField(image: Image(systemName: "person"))
                        .disableAutocorrection(true)
                        .focused(focus, equals: .fullname)
                        .submitLabel(.go)
                        .onSubmit {
                            if regViewModel.fullName != "" {
                                createUserWithEmailPassword()
                            } else {
                                regViewModel.errorMessage = "Please enter your full name to complete registration."
                            }
                        }
                        .onChange(of: regViewModel.email) { newValue in
                            regViewModel.errorMessage = ""
                        }
                        .onChange(of: regViewModel.password) { newValue in
                            regViewModel.errorMessage = ""
                        }
                        .onChange(of: regViewModel.fullName) { newValue in
                            regViewModel.errorMessage = ""
                        }
                }
                Button(action: createUserWithEmailPassword) {
                    if regViewModel.authenticationState != .authenticating {
                        HStack {
                            Image(systemName: "arrow.right")
                            Text("Sign up")
                                .customFont(.headline)
                        }
                    }
                    else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                    }
                }
                .largeButton()
                .disabled(!regViewModel.isValid)
                .onAppear {
                    regViewModel.connect(authenticationService: authenticationService)

                }
                
                if !regViewModel.errorMessage.isEmpty {
                    VStack {
                        Text(regViewModel.errorMessage)
                            .foregroundColor(Color(UIColor.systemRed))
                    }
                }
                
                HStack {
                    Rectangle().frame(height: 1).opacity(0.1)
                    Text("OR").customFont(.subheadline2).foregroundColor(.black.opacity(0.3))
                    Rectangle().frame(height: 1).opacity(0.1)
                }
                
                Button("Have an account? Sign in instead.") {
                    withAnimation(.spring()) {
                        showSignUp = false
                        regViewModel.errorMessage = ""
                    }
                }
                    .padding()
                    .customFont(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(30)
            .background(.regularMaterial)
            .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color("Shadow").opacity(0.3), radius: 5, x: 0, y: 3)
            .shadow(color: Color("Shadow").opacity(0.3), radius: 30, x: 0, y: 30)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.linearGradient(colors: [.white.opacity(0.8), .white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .padding()
            if !showSignUp {
                SignInView()
                    .opacity(showSignUp ? 1 : 0)
                    .offset(y: showSignUp ? 0 : 300)
                    .overlay(
                        Button {
                            withAnimation(.spring()) {
                                showSignUp.toggle()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .frame(width: 36, height: 36)
                                .foregroundColor(.black)
                                .background(.white)
                                .mask(Circle())
                                .shadow(color: Color("Shadow").opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .offset(y: showSignUp ? 0 : 200)
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .zIndex(1)
            }
        }
    }

