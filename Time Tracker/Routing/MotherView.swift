//
//  MotherView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI

struct MotherView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
//    @StateObject var dataController : DataController


    var body: some View {
            switch viewRouter.currentPage {
            case .onBoardingPage:
                OnboardingView().environmentObject(AuthenticationService())
                    .background(.white)
            case .loginPage:
                LoginPage().environmentObject(AuthenticationService())
            case .homePage:
                TabBarView()
        }
    }
}
