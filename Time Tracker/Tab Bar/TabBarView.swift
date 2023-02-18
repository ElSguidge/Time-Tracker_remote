//
//  TabBarView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI

struct TabBarView: View {
    
    @EnvironmentObject var dataController: DataController
//    @StateObject var dataController : DataController
//
//    init() {
//            let dataController = DataController()
//            _dataController = StateObject(wrappedValue: dataController)
//        }
    
    var body: some View {
        
            TabView {
                
                MapViewTimeLine().environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(dataController)
                    .tabItem {
                        Label("Location", systemImage: "mappin.and.ellipse")
                    }
                
                HomeView().environment(\.managedObjectContext, dataController.container.viewContext)
                    .environmentObject(dataController)
                    .tabItem {
                        Label("Timesheets", systemImage: "person.badge.clock")
                    }
                

                SettingsPage().environmentObject(AuthenticationService())
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
        }
    }
}
