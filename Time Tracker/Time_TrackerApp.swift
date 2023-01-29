//
//  Time_TrackerApp.swift
//  Time Tracker
//
//  Created by Mark McKeon on 7/12/2022.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import GoogleMaps

@main
struct Time_TrackerApp: App {
    
//    @StateObject var dataController : DataController
    @StateObject var viewRouter = ViewRouter()
    
    init() {
        FirebaseApp.configure()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let clientID = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"] {
                GMSServices.provideAPIKey(clientID)
            } else {
                print("Google maps api key not set")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            
            MotherView().environmentObject(viewRouter)
        }
    }
}
