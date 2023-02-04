//
//  CheckIntoProjectView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 3/2/2023.
//

import SwiftUI
import FirebaseFirestore

struct CheckIntoProjectView: View {
    @ObservedObject var authViewModel = AuthViewModel()
    var userProfile: UserProfile
    var projectClass: ProjectClass
    @State private var question1Checked = false
    @State private var question2Checked = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Check in to \(projectClass.name)")
                .font(.title)
            
            HStack {
                Text("Have you read and understood the relevant site specific SWMS?")
                Spacer()
                Checkbox(isChecked: $question1Checked, size: .init(width: 35, height: 35), innerShapeSizeRatio: 1/3)
            }
            .padding(.vertical)
            if question1Checked {
                if userProfile.checkedIn.projectAddress != projectClass.address || userProfile.checkedIn.projectAddress == projectClass.address && userProfile.checkedIn.isCheckedIn == false {
                    Button("Check in") {
                        let checkIn = CheckIn(isCheckedIn: true, projectName: projectClass.name, projectLocation: GeoPoint(latitude: projectClass.coordinate.latitude, longitude: projectClass.coordinate.longitude), projectAddress: projectClass.address, projectJobNumber: projectClass.jobNumber, date: Date())
                        print(checkIn)
                        UserProfileRepository().isCheckedIn(checkIn: checkIn, userId: authViewModel.userSession!.uid)
                    }
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
            }
        }
        .padding()
    }
}

//struct CheckIntoProjectView_Previews: PreviewProvider {
//    static var previews: some View {
//        CheckIntoProjectView()
//    }
//}
