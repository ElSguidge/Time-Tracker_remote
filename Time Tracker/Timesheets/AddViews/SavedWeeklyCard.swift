//
//  SavedWeeklyCard.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI

struct SavedWeeklyCard: View {
    
    
    let employee : Employee
    var timesheets : [Timesheet]
    var weeks : [Week]
    
    @Binding var showPicker: Bool 
    @Binding var selectedTemplate : String
    
    var savedWeekendingArray: [String] {
        return weeks.map { dateStrings(for: $0.weekEnding ?? Date.now) }
    }
    
    var body: some View {
        Section {
            
            Toggle(isOn: $showPicker) {
                Text("Copy saved timesheet")
            }
            if showPicker {
                withAnimation {
                    Picker(savedWeekendingArray.isEmpty ? "No saved timesheets" : "Select from saved", selection: $selectedTemplate) {
                        ForEach(savedWeekendingArray, id: \.self) { weekEndingSaved in
                            Text(weekEndingSaved)
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
