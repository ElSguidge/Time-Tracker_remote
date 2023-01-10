//
//  Observer.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class observer : ObservableObject{
    
    @Published var data = [String : Any]()
    
    init() {
        
        let db = Firestore.firestore()
        
        db.collection("locations").document("coordinate").addSnapshotListener { [self](snap, err) in
            
            if err != nil{
                
                print((err?.localizedDescription)!)
                return
            }
            
            if let updates = snap?.get("updates") as? [String : GeoPoint] {
                self.data = updates
            }
        }
    }
}
