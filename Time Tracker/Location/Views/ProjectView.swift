//
//  ProjectView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 27/1/2023.
//

import SwiftUI
import FirebaseFirestore
import GoogleMaps

struct ProjectView: View {
    
    @ObservedObject var authViewModel = AuthViewModel()
    var userProfile: UserProfile
    
    var projectClass: ProjectClass?
    @State private var showingCheckinPage: Bool = false
    
    var body: some View {
        
        
        Spacer()
        Spacer()
        Spacer()
        
        StreetViewRepresentable(project: projectClass ?? ProjectClass(coordinate: CLLocationCoordinate2D(latitude: -33.732, longitude: 150.312), name: "", address: "", jobNumber: ""))
        
        Text(projectClass?.name ?? "")
            .font(.system(size: 30))
            .fontWeight(.bold)
        VStack(alignment: .leading) {
            
            Text(projectClass?.address ?? "")
                .fontWeight(.bold)
            VStack(alignment: .leading) {
                Text("Job number: \(projectClass?.jobNumber ?? "")")
            }
        }
        if projectClass != nil {
            
            if userProfile.checkedIn.projectAddress != projectClass?.address ?? "" || userProfile.checkedIn.projectAddress == projectClass?.address ?? "" && userProfile.checkedIn.isCheckedIn == false {
                Button("Check in") {
                    self.showingCheckinPage = true
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .sheet(isPresented: $showingCheckinPage) {
                    CheckIntoProjectView(userProfile: userProfile, projectClass: projectClass!)
                }
            } else {
                Button("Check out") {
                    let checkout = CheckIn(isCheckedIn: false, projectName: projectClass!.name, projectLocation: GeoPoint(latitude: projectClass!.coordinate.latitude, longitude: projectClass!.coordinate.longitude), projectAddress: projectClass!.address, projectJobNumber: projectClass!.jobNumber, date: Date())
                    UserProfileRepository().isCheckedIn(checkIn: checkout, userId: authViewModel.userSession!.uid)
                }
                .frame(maxWidth: .infinity)
                .fontWeight(.semibold)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
    }
}

//struct ProjectView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectView()
//    }
//}
