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
        guard let clientID = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"] else { return }
        GMSServices.provideAPIKey(clientID)
    }
    
    var body: some Scene {
        WindowGroup {
            
            MotherView().environmentObject(viewRouter)
        }
    }
}
