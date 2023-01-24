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
    @Binding var level: String
    @Binding var showingCreateProject: Bool
    
    var body: some View {
        

                ZStack(alignment: .bottom, content: {
                    CreateProjectMapView(location: $location, title:  self.$title, subtitle: self.$subtitle)
                        .frame(height: 220)
                    
                    if self.title != "" {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill").font(.body).foregroundColor(.black)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                
                                Text(self.title).font(.body).foregroundColor(.black)
                                Text(self.subtitle).font(.caption).foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(15)
                    }
                    
                })
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
                    TextField("Level", text: $level)
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
                            Text("Dismiss")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.createProject(name: name, location: location!, address: "\(self.title), \(self.subtitle)", jobNumber: jobNumber, level: level)
                            showingCreateProject = false
                        } label: {
                            Text("Save")
                        }
                    }
                }
        }
        
    }
}

