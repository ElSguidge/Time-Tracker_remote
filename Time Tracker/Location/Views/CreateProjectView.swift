//
//  CreateProjectView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 20/1/2023.
//

import SwiftUI
import CoreLocation
import MapKit

struct CreateProjectView: View {
    @ObservedObject var viewModel = MapViewModel()
    @Binding var location: CLLocationCoordinate2D?
    
    @Binding var title: String
    @Binding var subtitle: String
    @Binding var name: String
    @Binding var address: String
    @Binding var jobNumber: String
    @Binding var showingCreateProject: Bool
    
    var body: some View {
        
        ZStack(alignment: .bottom, content: {
            CreateProjectMapView(location: $location, title:  self.$title, subtitle: self.$subtitle)
                .frame(height: 400)
            
            if self.title != "" {
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill").font(.largeTitle).foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        
                        Text(self.title).font(.body).foregroundColor(.black)
                        Text(self.subtitle).font(.caption).foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.white))
                .cornerRadius(15)
            }
            
        })
        
        Spacer()
        NavigationStack {
            Form {
                Section {
                    TextField("Project Name", text: $name)
                }
                Section(header: Text("Address")) {
                    if self.title != "" {
                        Text("\(self.title), \(self.subtitle)")
                    } else {
                        Text("")
                    }
                }
                Section {
                    TextField("Job Number", text: $jobNumber)
                }
            }
                
                Button("Save") {
                    viewModel.createProject(name: name, location: location!, address: "\(self.title), \(self.subtitle)", jobNumber: jobNumber)
                    showingCreateProject = false
                }
            
            
            
        }
        
    }
}

