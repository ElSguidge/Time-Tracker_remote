//
//  ViewRouter.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI

class ViewRouter: ObservableObject {
    static let shared = ViewRouter()
    
    @Published var currentPage: Page = .onBoardingPage
}

enum Page {
    case onBoardingPage
    case loginPage
    case homePage
}
