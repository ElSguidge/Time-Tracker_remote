//
//  DetailView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 8/12/2022.
//

import SwiftUI
import UIKit
import MessageUI

struct MainDetailView: View {
    @EnvironmentObject var dataController : DataController
    @Environment(\.managedObjectContext) var moc
    
    let employee : Employee
    
    var timesheets : [Timesheet]
    
    var weeks : [Week]
    
    var workExpenses: [WorkExpense]
    
    @StateObject var cards = Cards()
        
    @State private var showingAddTimecard : Bool = false
    @State var result: Result<MFMailComposeResult, Error>? = nil
    
    init(employee : Employee){
        self.employee = employee

        self.timesheets = employee.timesheets?.allObjects as! [Timesheet]
        self.timesheets = self.timesheets.sorted(by: {$0.weekEnding! < $1.weekEnding! })

        self.weeks = employee.weeks?.allObjects as! [Week]
        self.weeks = self.weeks.sorted(by: {$0.weekEnding! > $1.weekEnding! })
        
        self.workExpenses = employee.expenses?.allObjects as! [WorkExpense]
        self.workExpenses = self.workExpenses.sorted(by: {$0.weekEnding ?? Date() < $1.weekEnding ?? Date()})
    }
    
    var body: some View {
        Form {
            Section {
                Button {
                    self.showingAddTimecard = true
                } label: {
                    Label("Create a new timesheet", systemImage: "plus.circle.fill")
                }
            }
            Section (header: Text("My Timesheets")) {
                List {
                    ForEach(weeks) { week in
                        NavigationLink {
                            SavedTimecardDetailView(employee: employee, week: week)
                        } label: {
                            HStack {
                                Image(systemName: week.submitted ? "checkmark.circle.fill" : "x.circle.fill")
                                    .foregroundColor(week.submitted ? .green : .gray)
                                    .padding(5)
                                Text("\(dateStrings(for: week.weekEnding ?? Date()))")
                            }
                        }
                    }
                    .onDelete(perform: deleteTimecard)
                }
            }
            .navigationTitle(self.employee.name ?? "Anonymous")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddTimecard) {
                AddTimeCardView(employee: self.employee, timesheets: self.timesheets, weeks: self.weeks, workExpenses: self.workExpenses, cards: cards, result: $result).environmentObject(dataController)

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
    
    func deleteTimecard( at offsets: IndexSet) {
        for offset in offsets {
            let timecard = weeks[offset]
            for object in workExpenses {
                if object.weekEnding == weeks[offset].weekEnding {
                    dataController.delete(object)
                }
            }
            for timesheet in timesheets {
                if timesheet.weekEnding == weeks[offset].weekEnding {
                    dataController.delete(timesheet)
                }
            }
            dataController.delete(timecard)
        }
        dataController.save()
    }
}

