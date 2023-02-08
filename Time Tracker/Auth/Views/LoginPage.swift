//
//  LoginPage.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


struct LoginPage: View {
    
    enum FocusableField: Hashable {
        case email
        case password
        case fullname
    }
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var authenticationService: AuthenticationService
    @StateObject var viewModel = LoginViewModel()
    @StateObject var regViewModel = RegisterViewModel()
    @State var showSignUpForm = false
    @FocusState private var focus: FocusableField?
    @FocusState var isInputActive: Bool
    
    private func signInWithEmailPassword() {
            
        Task {
            if await viewModel.signInWithEmailPassword() == true {
                DispatchQueue.main.async {
                    withAnimation {
                        viewRouter.currentPage = .homePage
                    }
                }
            }
        }
    }

    
    var body: some View {
        VStack {
            LogoView()
            
            Text(showSignUpForm ? "Sign up" : "Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if self.showSignUpForm {
                
                RegisterPage(showSignUpForm: $showSignUpForm, focus: $focus)
//
            } else {
                HStack {
                    Image(systemName: "at")
                    TextField("Email", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focus, equals: .email)
                }
                .padding(.vertical, 6)
                .background(Divider(), alignment: .bottom)
                .padding(.bottom, 4)
 

                HStack {
                    Image(systemName: "lock")
                    SecureField("Password", text: $viewModel.password)
                        .focused($focus, equals: .password)
                        .submitLabel(.go)
                        .onSubmit {
                            signInWithEmailPassword()
                        }
                    
                }
                .padding(.vertical, 6)
                .background(Divider(), alignment: .bottom)
                .padding(.bottom, 8)

                if !viewModel.errorMessage.isEmpty {
                    VStack {
                        Text(viewModel.errorMessage)
                            .foregroundColor(Color(UIColor.systemRed))
                    }
                }

                Button(action: signInWithEmailPassword) {
                    if viewModel.authenticationState != .authenticating {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                    }
                    else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.isValid)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                HStack {
                    VStack { Divider() }
                    Text("or")
                    VStack { Divider() }
                }

                Button(action: { }) {
                    Image(systemName: "applelogo")
                        .frame(maxWidth: .infinity)
                }
                .foregroundColor(.black)
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            HStack {
                Text(showSignUpForm ? "Have an account? Sign in instead." : "Don't have an account yet?")
                Button(action: { self.showSignUpForm.toggle()}) {
                    Text(showSignUpForm ? "Sign in" : "Sign up")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding([.top, .bottom], 50)
            .onAppear {
                viewModel.connect(authenticationService: authenticationService)
            }
            .listStyle(.plain)
            .padding()

        }

    }
}

struct LogoView: View {
    var body: some View {
        Image("Logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 300, height: 150)
            .padding(.top, 70)
    }
}

