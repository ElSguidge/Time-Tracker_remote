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
    @StateObject private var viewModel = MapViewModel()
    @State private var showingUserPage = false
    @State private var annotations: [MKPointAnnotation] = []
    @State private var showingCreateProject = false

    @State private var name = ""
    @State private var location: CLLocationCoordinate2D?
    @State private var address = ""
    @State private var jobNumber = ""
    
    @State private var title = ""
    @State private var subtitle = ""
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                mapView(userProfiles: viewModel.userProfiles, geopoints: self.obs.data as! [String : GeoPoint], annotations: annotations)
                    .edgesIgnoringSafeArea(.top)
                HStack {
                    Button(action: {
                        // show an action sheet or a modal view to create a project
                        showingCreateProject = true
                    }) {
                        HStack {
                            Label("Create Project", systemImage: "plus")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }

                }
                VStack(alignment: .trailing) {
                    Spacer()
                    Button(action: {
                        showingUserPage = true
                    }) {
                        HStack {
                            Label("My Team", systemImage: "person")
                        }
                        .padding()
                        .background(Color.pink.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                    }
                    .sheet(isPresented: $showingUserPage) {
                        UserListView(userProfiles: viewModel.userProfiles)
                    }
                    .sheet(isPresented: $showingCreateProject) {
                        CreateProjectView(viewModel: self.viewModel, location: $location, title: $title, subtitle: $subtitle, name: $name, address: $address, jobNumber: $jobNumber, showingCreateProject: $showingCreateProject)
                    }
                }
            }
            .onAppear {
                viewModel.checkIfLocationServicesIsEnabled()
                annotations = createAnnotations()
            }
        }
        
    }
    
    private func createAnnotations() -> [MKPointAnnotation] {
        var annotations: [MKPointAnnotation] = []
            for(uid, geoPoint) in obs.data as! [String : GeoPoint] {
                if uid != authViewModel.userSession?.uid {
                    let userProfile = viewModel.userProfiles.first { $0.uid == uid }
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                    annotation.title = userProfile?.fullName
                    annotations.append(annotation)
                }
        }
        return annotations
    }
}

struct mapView: UIViewRepresentable {
    
    @ObservedObject var authViewModel = AuthViewModel()
    
    var userProfiles: [UserProfile]
    var geopoints : [String: GeoPoint]
    var annotations: [MKPointAnnotation]
    
    func makeCoordinator() -> Coordinator {
        
        return mapView.Coordinator(parent1: self)
    }
    
    let map = MKMapView()
    let manager = CLLocationManager()
    //
    func makeUIView(context: Context) -> MKMapView {
        
        manager.delegate = context.coordinator
        manager.startUpdatingLocation()
        map.showsUserLocation = true
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.5))
        map.region = region
        map.addAnnotations(annotations)
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
//        uiView.addAnnotations(annotations)
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
    }
    
    class Coordinator: NSObject, CLLocationManagerDelegate {
        
        @ObservedObject var authViewModel = AuthViewModel()
        
        var parent: mapView
        
        init(parent1: mapView) {
            
            parent = parent1
            
        }
    }
}

