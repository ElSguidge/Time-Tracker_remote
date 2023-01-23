//
//  CreateProjectMapView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 22/1/2023.
//

import SwiftUI
import CoreLocation
import MapKit


struct CreateProjectMapView: UIViewRepresentable {
    @Binding var location: CLLocationCoordinate2D?
    @Binding var title: String
    @Binding var subtitle: String
    
    func makeCoordinator() -> CreateProjectMapView.Coordinator {
        return CreateProjectMapView.Coordinator(parent1: self)
    }
    
    
    func makeUIView(context: UIViewRepresentableContext<CreateProjectMapView>) -> MKMapView {
        
        let map = MKMapView()
        let coordinate = CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631)
        map.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.5))
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        map.delegate = context.coordinator

        map.addAnnotation(annotation)
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<CreateProjectMapView>) {
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CreateProjectMapView

        init(parent1: CreateProjectMapView) {
            parent = parent1
        }
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let pin = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pin.isDraggable = true
            
            return pin
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            
            if newState == .ending {
                   self.parent.location = CLLocationCoordinate2D(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
               }

            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)) { (places, err) in
                
                if err != nil {
                    
                    print((err?.localizedDescription)!)
                    return
                }

                self.parent.title = (places?.first?.name ?? places?.first?.postalCode)!
                self.parent.subtitle = (places?.first?.locality ?? places?.first?.country ?? "None")
            }
        }
    }

}

