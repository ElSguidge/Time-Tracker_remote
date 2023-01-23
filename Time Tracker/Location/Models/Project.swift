//
//  File.swift
//  Time Tracker
//
//  Created by Mark McKeon on 19/1/2023.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct Project: Codable {
    @DocumentID var id: String?
    let name: String
    let location: GeoPoint
    let address: String
    let jobNumber: String
}

extension Project {
    func toDict() -> [String: Any] {
        return ["name": name, "location": location, "address": address, "jobNumber": jobNumber]
    }
}
