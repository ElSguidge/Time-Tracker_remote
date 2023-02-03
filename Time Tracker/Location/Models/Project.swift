//
//  File.swift
//  Time Tracker
//
//  Created by Mark McKeon on 19/1/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import MapKit


struct Project: Codable, Equatable, Hashable {
    @DocumentID var id: String?
    let name: String
    let location: GeoPoint
    let address: String
    let jobNumber: String
    
    func toProjectClass() -> ProjectClass {
            return ProjectClass(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), name: name, address: address, jobNumber: jobNumber)
        }
}

extension Project {
    func toDict() -> [String: Any] {
        return ["name": name, "location": location, "address": address, "jobNumber": jobNumber]
    }
}


class ProjectClass: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    let name: String
    let address: String
    let jobNumber: String
    
    init(
        coordinate: CLLocationCoordinate2D,
        name: String,
        address: String,
        jobNumber: String
    ) {
        self.coordinate = coordinate
        self.name = name
        self.address = address
        self.jobNumber = jobNumber
        
        super.init()
    }
    
    var title: String? {
        return name
    }
    var subtitle: String? {
        return address
    }
    
    func toProject() -> Project {
        return Project(name: name, location: GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude), address: address, jobNumber: jobNumber)
    }

}

