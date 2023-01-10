//
//  Time_TrackerApp.swift
//  Time Tracker
//
//  Created by Mark McKeon on 7/12/2022.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

@main
struct Time_TrackerApp: App {
    
//    @StateObject var dataController : DataController
    @StateObject var viewRouter = ViewRouter()
    
    init() {
        FirebaseApp.configure()

    }
    var body: some Scene {
        WindowGroup {
            
            MotherView().environmentObject(viewRouter)
//            HomeView()
//                .environment(\.managedObjectContext, dataController.container.viewContext)
//                .environmentObject(dataController)
//                .preferredColorScheme(.dark)
        }
    }
}
