//
//  TabBarView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI

struct TabBarView: View {
    
    @StateObject var dataController : DataController
    
    var body: some View {
        NavigationStack {
            TabView {

                HomeView().environment(\.managedObjectContext, dataController.container.viewContext)
                            .environmentObject(dataController)
                    .tabItem {
                        Label("Timesheets", systemImage: "person.badge.clock")
                    }
                MapViewTimeLine()
                    .tabItem {
                        Label("Location", systemImage: "mappin.and.ellipse")
                    }
                SettingsPage().environmentObject(AuthenticationService())
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
        }
    }
}
