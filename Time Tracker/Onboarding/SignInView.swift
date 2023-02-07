//
//  SignInView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 7/2/2023.
//

import SwiftUI
import RiveRuntime

struct SignInView: View {
    @State var email = ""
    @State var password = ""
    @State var isLoading = false
    @State private var showSignUp: Bool = false
//    @Binding var show: Bool
//    let confetti = RiveViewModel(fileName: "confetti", stateMachineName: "State Machine 1")
    let check = RiveViewModel(fileName: "check", stateMachineName: "State Machine 1")
    
    func logIn() {
        isLoading = true
        
        if email != "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                check.triggerInput("Check")
            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                confetti.triggerInput("Trigger explosion")
//                withAnimation {
//                    isLoading = false
//                }
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//                withAnimation {
//                    show.toggle()
//                }
//            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                check.triggerInput("Error")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isLoading = false
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
                TextField("", text: $email)
                    .customTextField(image: Image(systemName: "at"))
            }
            VStack(alignment: .leading) {
                Text("Password")
                    .customFont(.subheadline)
                    .foregroundColor(.secondary)
                SecureField("", text: $password)
                    .customTextField(image: Image(systemName: "lock"))
            }
            Button {
                logIn()
            } label: {
                HStack {
                    Image(systemName: "arrow.right")
                    Text("Sign in")
                        .customFont(.headline)
                }
                .largeButton()
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
        .overlay(
            ZStack {
                if isLoading {
                    check.view()
                        .frame(width: 100, height: 100)
                        .allowsHitTesting(false)
                }
//                confetti.view()
//                    .scaleEffect(3)
//                    .allowsHitTesting(false)
            }
        )
        .padding()
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
