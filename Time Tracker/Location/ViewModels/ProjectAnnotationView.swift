//
//  ProjectAnnotationView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 11/2/2023.
//

import Foundation
import SwiftUI
import MapKit


final class ProjectAnnotationView: MKMarkerAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setupUI()
    }
    
    private func setupUI() {
        canShowCallout = true
        markerTintColor = .blue
    }
}
