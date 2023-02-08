//
//  SignInView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 7/2/2023.
//

import SwiftUI
import RiveRuntime

struct SignInView: View {
    
    enum FocusableField: Hashable {
        case email
        case password
        case fullname
    }
    
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var authenticationService: AuthenticationService
    @StateObject var viewModel = LoginViewModel()
    @StateObject var regViewModel = RegisterViewModel()
    @State var isLoading = false
    @State private var showSignUp: Bool = false
    @FocusState private var focus: FocusableField?

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
        VStack(spacing: 24) {
            Text("Sign in")
                .customFont(.largeTitle)
            Text("Start checking into real projects now and create timesheets with ease.")
                .foregroundColor(.secondary)
            VStack(alignment: .leading) {
                Text("Email")
                    .customFont(.subheadline)
                    .foregroundColor(.secondary)
                TextField("", text: $viewModel.email)
                    .customTextField(image: Image(systemName: "at"))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focus, equals: .email)
            }
            VStack(alignment: .leading) {
                Text("Password")
                    .customFont(.subheadline)
                    .foregroundColor(.secondary)
                SecureField("", text: $viewModel.password)
                    .customTextField(image: Image(systemName: "lock"))
                    .focused($focus, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        signInWithEmailPassword()
                    }
                    .onChange(of: viewModel.email) { newValue in
                        viewModel.errorMessage = ""
                    }
                    .onChange(of: viewModel.password) { newValue in
                        viewModel.errorMessage = ""
                    }

            }
            Button(action: signInWithEmailPassword) {
                if viewModel.authenticationState != .authenticating {
                    HStack {
                        Image(systemName: "arrow.right")
                        Text("Sign in")
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
            .disabled(!viewModel.isValid)
            
            if !viewModel.errorMessage.isEmpty {
                VStack {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
            
            HStack {
                Rectangle().frame(height: 1).opacity(0.1)
                Text("OR").customFont(.subheadline2).foregroundColor(.black.opacity(0.3))
                Rectangle().frame(height: 1).opacity(0.1)
            }
            
            Button("Sign up with Email.") {
                withAnimation(.spring()) {
                    showSignUp = true
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
        .onAppear {
            viewModel.connect(authenticationService: authenticationService)
        }

        if showSignUp {
            SignUpView(showSignUp: $showSignUp)
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
