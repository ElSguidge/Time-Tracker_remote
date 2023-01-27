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
    @Environment(\.presentationMode) var presentationMode
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
                        .frame(height: 300)
                })
        
        NavigationStack {
            Form {
                
                Section(header: Text("Address")) {
                    if self.title != "" {
                        Text("\(self.title), \(self.subtitle)")
                    } else {
                        Text("")
                    }
                }
                
                Section {
                    TextField("Project Name", text: $name)
                }

                Section {
                    TextField("Job Number", text: $jobNumber)
                }
            }
                    
                .navigationTitle("Add a project")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                    
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                viewModel.createProject(name: name, location: location!, address: "\(self.title), \(self.subtitle)", jobNumber: jobNumber)
                                showingCreateProject = false
                            } label: {
                                Text("Save")
                            }
                        }
                }
        }
        
    }
}

