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
    
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                mapView(userProfiles: viewModel.userProfiles, geopoints: self.obs.data as! [String : GeoPoint])
                    .edgesIgnoringSafeArea(.top)
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
                }
            }
            .onAppear {
                viewModel.checkIfLocationServicesIsEnabled()
            }
        }
        
    }
}

struct mapView: UIViewRepresentable {
    
    @ObservedObject var authViewModel = AuthViewModel()
    
    var userProfiles: [UserProfile]
    var geopoints : [String: GeoPoint]
    
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
    }
    
    class Coordinator: NSObject, CLLocationManagerDelegate {
        
        @ObservedObject var authViewModel = AuthViewModel()
        
        var parent: mapView
        
        init(parent1: mapView) {
            
            parent = parent1
            
        }
    }
}

