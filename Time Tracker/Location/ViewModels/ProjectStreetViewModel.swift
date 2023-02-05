//
//  ProjectStreetViewModel.swift
//  Time Tracker
//
//  Created by Mark McKeon on 27/1/2023.
//

import Foundation
import GoogleMaps
import SwiftUI

class StreetView: UIViewController {

  
    let panoView = GMSPanoramaView(frame: .zero)
    
    override func loadView() {
        self.view = panoView
    }
    func updateCoordinates(coordinate: CLLocationCoordinate2D) {
        panoView.moveNearCoordinate(coordinate)
    }
  }

struct StreetViewRepresentable: UIViewControllerRepresentable {

    let project: ProjectClass

    func makeUIViewController(context: Context) -> StreetView {
        let streetViewController = StreetView()
        streetViewController.loadView()
        streetViewController.updateCoordinates(coordinate: CLLocationCoordinate2D(latitude: project.coordinate.latitude, longitude: project.coordinate.longitude))
        return streetViewController
    }

    func updateUIViewController(_ uiViewController: StreetView, context: Context) {
        uiViewController.updateCoordinates(coordinate: CLLocationCoordinate2D(latitude: project.coordinate.latitude, longitude: project.coordinate.longitude))
    }
}
