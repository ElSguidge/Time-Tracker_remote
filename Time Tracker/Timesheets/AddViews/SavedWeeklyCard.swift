//
//  SavedWeeklyCard.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI

struct SavedWeeklyCard: View {
    
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var dataController : DataController
    @Environment(\.managedObjectContext) var moc
    
    let employee : Employee
    var timesheets : [Timesheet]
    var weeks : [Week]
    
    @State private var showPicker: Bool = false
    @State private var selectedTemplate = ""
    
    var weekEndingArray: [String] {
        return weeks.map { dateStrings(for: $0.weekEnding ?? Date.now) }
    }
  
    var body: some View {
        Section {
            
            Toggle(isOn: $showPicker) {
                Text("Auto fill timesheet?")
            }
            
            if showPicker {
                withAnimation {
                    Picker("Select from saved", selection: $selectedTemplate) {
                        ForEach(weekEndingArray, id: \.self) { weekEnding in
                            Text(weekEnding)
                            }
                    }
                }
            }
        }
    }
    
    func dateStrings(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.setLocalizedDateFormatFromTemplate("y-MM-dd")
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}

//struct SavedWeeklyCard_Previews: PreviewProvider {
//    static var previews: some View {
//        SavedWeeklyCard()
//    }
//}
