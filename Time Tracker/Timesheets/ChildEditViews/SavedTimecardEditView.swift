//
//  SavedTimecardEditView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 29/12/2022.
//

import SwiftUI

struct SavedTimecardEditView: View {
    
    @EnvironmentObject var dataController : DataController
    @Environment(\.managedObjectContext) var moc

    
    let employee: Employee
    var timesheet: Timesheet
    
    @State private var weekArray = [String]()
    @State private var projectName = ""
    
    var body: some View {

            TextField("Test", text: $projectName)
                .onChange(of: projectName) { newValue in
                    timesheet.projectName = projectName
                    dataController.save()
                }
                .task {
                    projectName = timesheet.projectName ?? ""
                }
            .onAppear {
                self.projectName = self.timesheet.projectName ?? ""
            }
    }
}
//
//struct SavedTimecardEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        SavedTimecardEditView()
//    }
//}
