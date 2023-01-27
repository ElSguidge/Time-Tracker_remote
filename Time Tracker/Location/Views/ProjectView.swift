//
//  ProjectView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 27/1/2023.
//

import SwiftUI

struct ProjectView: View {
    
    var project: ProjectClass?
    
    var body: some View {
        NavigationStack {
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
            
            
            .navigationTitle(project?.name ?? "")
        }
        
    }
}

//struct ProjectView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectView()
//    }
//}
