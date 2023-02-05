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
        
        if let clientId = Bundle.main.infoDictionary?["GOOGLE_MAPS_API_KEY"] as? String {
            GMSServices.provideAPIKey(clientId)
        } else {
            print("Google maps api key not set")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            
            MotherView().environmentObject(viewRouter)
        }
    }
}
