//
//  ProjectView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 27/1/2023.
//

import SwiftUI
import GoogleMaps

struct ProjectView: View {
    
    var project: ProjectClass?
    
    var body: some View {
        

            Spacer()
            Spacer()
            Spacer()
            
            StreetViewRepresentable(project: project ?? ProjectClass(coordinate: CLLocationCoordinate2D(latitude: -33.732, longitude: 150.312), name: "", address: "", jobNumber: ""))
        
        Text(project?.name ?? "")
            .font(.system(size: 30))
            .fontWeight(.bold)
            VStack(alignment: .leading) {
                
                Text(project?.address ?? "")
                    .fontWeight(.bold)
                VStack(alignment: .leading) {
                    Text("Job number: \(project?.jobNumber ?? "")")
                }
            }
            Button("Check in") {}
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
    }
}

//struct ProjectView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectView()
//    }
//}
