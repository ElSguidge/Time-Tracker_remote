//
//  MapViewTimeLine.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import CoreLocation
import MapKit

struct MapViewTimeLine: View {
    @ObservedObject var authViewModel = AuthViewModel()
    @ObservedObject var obs = observer()
    @StateObject var viewModel = MapViewModel()
    @State private var showingUserPage = false
    @State private var annotations: [ProjectClass] = []
    @State private var showingCreateProject = false
    @State private var showingCheckInPage = false
    
    @State private var name = ""
    @State private var location: CLLocationCoordinate2D?
    @State private var address = ""
    @State private var jobNumber = ""
    
    @State private var title = ""
    @State private var subtitle = ""
    
    @State private var showingProjectInfo = false
    @State private var selectedProject: ProjectClass?
    @State private var settingsDetent = PresentationDetent.large
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                MapView(userProfiles: viewModel.userProfiles, geopoints: self.obs.data as! [String : GeoPoint], annotations: annotations, projects: viewModel.projects, showingProjectInfo: $showingProjectInfo, selectedProject: $selectedProject)
                    .edgesIgnoringSafeArea(.top)
                    .sheet(isPresented: $showingProjectInfo) {
                        if selectedProject != nil {
                            withAnimation {
                                ProjectView(userProfile: viewModel.userProfile, projectClass: self.selectedProject)
                                    .presentationDetents(
                                        [.medium, .large],
                                        selection: $settingsDetent)
                            }
                        } else {
                            withAnimation {
                                ProgressView("Fetching project from database...")
                                    .presentationDetents(
                                        [.medium, .large],
                                        selection: $settingsDetent)
                            }
                        }
                    }
                HStack(alignment: .top) {
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack {
                            Button(action: {
                                showingCreateProject = true
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                        .font(.system(size: 25))
                                        .fontWeight(.bold)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            
                        }
                        .padding()
                        
                        HStack(alignment: .top) {
                            Button(action: {
                                withAnimation {
                                    showingUserPage = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "person.3.fill")
                                }
                                .padding()
                                .background(Color.pink.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        HStack(alignment: .top) {
                            Button(action: {
                                withAnimation {
                                    showingCheckInPage = true
                                }
                            }) {
                                HStack {
                                    Image(systemName: "person.crop.circle.badge.checkmark")
                                        .font(.system(size: 25))
                                        .fontWeight(.bold)
                                }
                                .padding()
                                .background(Color.yellow.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                    
                    .sheet(isPresented: $showingCheckInPage) {
                        withAnimation {
                            HomeCheckInView(userProfile: viewModel.userProfile)
                            }
                    }
                    
                    .sheet(isPresented: $showingUserPage) {
                        withAnimation {
                            UserListView(userProfiles: viewModel.userProfiles)
                        }
                    }
                    .sheet(isPresented: $showingCreateProject) {
                        CreateProjectView(viewModel: self.viewModel, location: $location, title: $title, subtitle: $subtitle, name: $name, address: $address, jobNumber: $jobNumber, showingCreateProject: $showingCreateProject)
                    }
                }
                .onAppear {
                    viewModel.checkIfLocationServicesIsEnabled()
                    annotations = createAnnotations()
                }
            }
        }
    }
    
    private func createAnnotations() -> [ProjectClass] {
        var annotations: [ProjectClass] = []
        for project in viewModel.projects {
            
            let annotation = ProjectClass(
                coordinate: CLLocationCoordinate2D(latitude: project.location.latitude,
                                                   longitude: project.location.longitude),
                name: project.name,
                address: project.address,
                jobNumber: project.jobNumber)
            annotations.append(annotation)
            
        }
        return annotations
    }
    
}

struct MapView: UIViewRepresentable {
    
    @ObservedObject var authViewModel = AuthViewModel()
    
    var userProfiles: [UserProfile]
    var geopoints : [String: GeoPoint]
    var annotations: [ProjectClass]
    var projects: [Project]
    @Binding var showingProjectInfo: Bool
    @Binding var selectedProject: ProjectClass?
    
    func makeCoordinator() -> Coordinator {
        
        return MapView.Coordinator(parent1: self)
    }
    
    let map = MKMapView()
    let manager = CLLocationManager()
    
    func makeUIView(context: Context) -> MKMapView {
        
        map.delegate = context.coordinator
        manager.startUpdatingLocation()
        map.showsUserLocation = true
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.5))
        map.region = region
        map.register(ProjectAnnotationView.self, forAnnotationViewWithReuseIdentifier: "Project Annotation")

        return map
    }
    
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
    

        
        for i in geopoints {

            let point = MKPointAnnotation()

            if i.key != authViewModel.userSession?.uid {
                let userProfile = userProfiles.first { $0.uid == i.key }
                point.coordinate = CLLocationCoordinate2D(latitude: i.value.latitude, longitude: i.value.longitude)
                point.title = userProfile?.fullName

                uiView.removeAnnotations(uiView.annotations)
                uiView.addAnnotation(point)
            }

        }

        for project in projects {
            let projectClass = project.toProjectClass()
            uiView.addAnnotation(projectClass)
        }
    }
    
    class Coordinator: NSObject, CLLocationManagerDelegate, MKMapViewDelegate {
        
        @ObservedObject var authViewModel = AuthViewModel()
        
        var parent: MapView
        
        init(parent1: MapView) {
            
            parent = parent1
            
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
        switch annotation {
            case is ProjectClass:
                return mapView.dequeueReusableAnnotationView(withIdentifier: "Project Annotation", for: annotation)
            default:
                return nil
            }
        }

        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let projectAnnotation = view.annotation as? ProjectClass {
                self.parent.selectedProject = projectAnnotation
                self.parent.showingProjectInfo = true
                
            }
        }
        
    }
}


