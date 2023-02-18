//
//  CreateProjectView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 20/1/2023.
//

import SwiftUI
import CoreLocation
import MapKit
import Combine

struct CreateProjectView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: MapViewModel
    
    @Binding var location: CLLocationCoordinate2D?
    @Binding var title: String
    @Binding var subtitle: String
    @Binding var name: String
    @Binding var address: String
    @Binding var jobNumber: String
    @Binding var showingCreateProject: Bool
    
    @State private var keyboardHeight: CGFloat = 0
    @State private var showAlert: Bool = false
    
    var body: some View {
        
        ZStack {
                CreateProjectMapView(location: $location, title:  self.$title, subtitle: self.$subtitle)
                    .frame(maxWidth: .infinity, maxHeight: 500)
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    HStack {
                        Spacer()
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                            self.name = ""
                            self.title = ""
                            self.jobNumber = ""
                            self.address = ""
                            self.location = nil
                        } label: {
                            Image(systemName: "x.circle.fill")
                                .customFont(.largeTitle)
                                .foregroundColor(.secondary)
                        }

                    }
                    .padding(.top, 5)
                    Spacer()
                }
            }
        }
        ScrollView {
            VStack(spacing: 24) {
                Text("Add a project")
                    .customFont(.largeTitle)
                HStack(spacing: 24) {
                        Text("Project address: ")
                            .customFont(.subheadline)
                            .foregroundColor(.secondary)
                    if self.title != "" {
                        Text("\(self.title), \(self.subtitle)")
                    }
                }
                VStack(alignment: .leading) {
                    Text("Project Name")
                        .customFont(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("", text: $name)
                        .customTextField(image: Image(systemName: "folder"))
                    Text("Project Number")
                        .customFont(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("", text: $jobNumber)
                        .customTextField(image: Image(systemName: "number"))
                }
                if self.name != "" && self.jobNumber != "" && self.title != "" {
                    Button("Save project") {
                        viewModel.createProject(name: name, location: location!, address: "\(self.title), \(self.subtitle)", jobNumber: jobNumber)
                        self.showAlert = true
                    }
                    .customFont(.headline)
                    .largeButton()
                    .alert(isPresented: $showAlert) {
                        switch viewModel.alertState {
                            case .success:
                                return Alert(title: Text("Project created."), message: nil, dismissButton: .default(Text("OK")){
                                    self.showingCreateProject = false
                                    self.name = ""
                                    self.title = ""
                                    self.jobNumber = ""
                                    self.address = ""
                                    self.location = nil
                                })
                            case .exists:
                                return Alert(title: Text("Project already exists."), message: Text("The project details you have entered already exists."), dismissButton: .default(Text("OK")))
                            case .error:
                                return Alert(title: Text("Error."), message: Text("There was an error in creating this project. Please try again."), dismissButton: .default(Text("OK")))
                            case .none:
                                return Alert(title: Text("Incorrect data"), dismissButton: .default(Text("OK")))
                        }
                    }
                }
                
            }
            .padding()
            //        .padding(.bottom, keyboardHeight)
            //        .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
        }
        
    }
}

