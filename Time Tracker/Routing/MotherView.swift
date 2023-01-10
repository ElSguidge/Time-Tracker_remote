//
//  MotherView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI

struct MotherView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        switch viewRouter.currentPage {
        case .registerPage:
            RegisterPage().environmentObject(AuthenticationService())
        case .loginPage:
            LoginPage().environmentObject(AuthenticationService())
        case .homePage:
            TabBarView()
        }
    }
}
