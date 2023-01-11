//
//  TimecardDetailView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 8/12/2022.
//

import SwiftUI
import Foundation

struct SavedTimecardDetailView: View {
    
    let employee: Employee
    
    var week : Week
    
    @State private var tempWeekArray = Set<String>()
    @State private var showingEditView = false
    
    var timesheets: [Timesheet] {
        employee.timesheets?.allObjects as? [Timesheet] ?? []
    }
    
    var workExpenses: [WorkExpense] {
        employee.expenses?.allObjects as? [WorkExpense] ?? []
    }
    
    var totalExpenses: String {
        let expenses = workExpenses.filter { $0.weekEnding! == week.weekEnding }
        let totalAmount = expenses.reduce(0.0) { $0 + ($1.amount)}
        return String(totalAmount.formatted())
    }
    
    var filteredArray: [Timesheet] {

        return timesheets.filter { $0.weekEnding! == week.weekEnding }.sorted { stringToDate(date: $0.day!) < stringToDate(date: $1.day! ) }
    }

    var body: some View {
        NavigationStack {
            Form {
                        Section(header: Text("Date saved")) {
                            Text("\(week.date ?? Date())")
                        }
                Section(header: Text("Status")) {
                    Text(week.submitted ? "Submitted" : "Saved only")
                }
                Section(header: Text("Total hours")) {
                    Text("Total: \(week.totalHours ?? "")")
                        Text("Normal: \(week.totalHoursNormal ?? "" )")
                        Text("Overtime: \(week.totalHoursOvertime ?? "")")
                }
                Section(header: Text("Total Expenses")) {
                    Text("Total: \(totalExpenses)")

                }
                List {
                    ForEach(tempWeekArray.sorted{stringToDate(date: $0) < stringToDate(date: $1)}, id: \.self) { dates in
                        Section(header: Text(dates)) {
                            ForEach(filteredArray) { section in
                                if dates == section.day! {
                                    HCard(card: section)

                                    ForEach(workExpenses) { item in
                                        if item.date! == section.day && item.projectNumber! == section.projectNumber {
                                                Text("\(item.expenseType!): $\(item.amount.formatted())")
                                                if item.image != nil {
                                                    Image(uiImage: UIImage(data: item.image!)!)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 180, height: 180)
                                                }
                                                if item.comment! != "" {
                                                    Text("\(item.comment!)")
                                                }
                                            }
                                    }
//                                    .sheet(isPresented: $showingEditView) {
//                                        SavedTimecardEditView(employee: self.employee, timesheet: section)
//                                    }
                                }

                            }
                          }
                        
                        }
                    }
                }

            .onAppear {
                generateWeekSections()
            }
            .navigationTitle("\(dateToString(for: week.weekEnding ?? Date.now))")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        showingEditView = true
//                    } label: {
//                        Text("Edit")
//                    }
//                }
//            }

        }
    }

    func dateToString(for date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func generateWeekSections() {
        for days in filteredArray {
            tempWeekArray.insert(days.day!)
        }
    }
    
    func stringToDate(date: String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "EEEE, dd MMMM yyyy"
        
        let stringDate = date
        let newDate = dateFormatter.date(from: stringDate)
        return newDate ?? Date.now
    }
}

//struct TimecardDetailView_Previews: PreviewProvider {
//    static var dataController = DataController()
//
//    static var previews: some View {
//        let timecard = Timesheet(context: dataController.container.viewContext)
//        timecard.
//        TimecardDetailView()
//    }
//}
