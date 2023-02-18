//
//  OnboardingView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 6/2/2023.
//

import SwiftUI
import RiveRuntime

struct OnboardingView: View {
    @EnvironmentObject var viewRouter: ViewRouter
    let button = RiveViewModel(fileName: "button", autoPlay: false)
    @State private var showModal = false
    
    var body: some View {
        ZStack {
            Color("Shadow").ignoresSafeArea()
                .opacity(showModal ? 0.4 : 0)
            
            content
                .offset(y: showModal ? -50 : 0)
                .onAppear {
                    NotificationDelegate.shared.checkNotificationPermission { granted in
                        if granted {
                            NotificationDelegate.shared.scheduleInitialNotification()
                        } else {
                            NotificationDelegate.shared.showNotificationPermissionAlert()
                        }
                    }
                }
            if showModal {
                SignInView()
                    .opacity(showModal ? 1 : 0)
                    .offset(y: showModal ? 0 : 300)
                    .overlay(
                        Button {
                            withAnimation(.spring()) {
                                showModal.toggle()
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
                        .offset(y: showModal ? 0 : 200)
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .zIndex(1)
            }
        }
    }

    var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Start tracking time.")
                .font(Font.custom("Poppins Bold", size: 60))
                .frame(width: 270, alignment: .leading)
            
            Text("Don't miss a beat. Find team members easily and start saving time. Complete online timesheets with ease.")
                .customFont(.body)
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            button.view()
                .frame(width: 236, height: 64)
                .background(
                    Color.black
                        .cornerRadius(30)
                        .blur(radius: 10)
                        .opacity(0.3)
                        .offset(y: 10)
                )
                .overlay(
                    Label("Get started", systemImage: "arrow.forward")
                        .offset(x: 4, y: 4)
                        .customFont(.headline)
                        .accentColor(.primary)
                )
                .onTapGesture {
                    button.play(animationName: "active")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.spring()) {
                            showModal.toggle()
//                            viewRouter.currentPage = .loginPage
                        }
                    }
                }
            
            Text("This app requires user location services to be enabled. Please consider this before registering.")
                .customFont(.footnote)
                .opacity(0.7)
        }
        .padding(40)
        .padding(.top, 40)
        .background(
            RiveViewModel(fileName: "shapes").view()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .blur(radius: 30)
                .blendMode(.hardLight)
        )
        .background(
            Image("backImage")
                .blur(radius: 50)
                .offset(x: 200, y: 100)
        )
    }
}
//struct OnboardingView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingView()
//    }
//}
