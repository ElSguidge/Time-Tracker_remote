//
//  Timecard.swift
//  Time Tracker
//
//  Created by Mark McKeon on 24/12/2022.
//

import SwiftUI

struct Timecard: View {
    
    @Binding var card: [Card]
    @Binding var workDay: String

    var isInputActive: FocusState<DailyDetailView.Field?>.Binding

    let departments = ["31", "32", "56", "44"]
    let jobCodes = ["2647 - Public Holiday", "2466 - RDO", "2455 - Meeting", "2432 - Office"]
    
    var body: some View {
        
        ForEach($card) { item in

            Section {
                Picker("Department", selection: item.department) {
                    ForEach(departments, id: \.self) {
                        Text($0)
                    }
                }
                TextField("Job Number", text: item.jobNumber)
                    .focused(isInputActive, equals: .jobNumber)

                TextField("Work Code (Enter 9999 for generic codes)", text: item.jobCode)
                    .focused(isInputActive, equals: .jobCode)


                if item.jobCode.wrappedValue == "9999" {

                    Section {
                        Picker("Work Code", selection: item.jobCode) {
                            ForEach(jobCodes, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                }
                TextField("Project name", text: item.jobName)
                    .focused(isInputActive, equals: .projectName)
                Stepper("\(item.hours.wrappedValue.formatted()) Normal Hours", value: item.hours, in: 0...16, step: 0.5)
                Stepper("\(item.overtime.wrappedValue.formatted()) Overtime Hours", value: item.overtime, in: 0...16, step: 0.5)
                Text("Total Hours: \(calculateTotal(normal: item.hours.wrappedValue, overtime: item.overtime.wrappedValue))")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .listRowBackground(Color.green.opacity(0.7))
            }
            Section {
                Button {
                    withAnimation {
                        item.wrappedValue.addExpenses()
                    }

                } label: {
                    Label("Add expenses", systemImage: "plus.circle.fill")
                }
                if item.expenses.count >= 1 {
                    Button {
                        withAnimation {
                            item.wrappedValue.deleteExpenses()
                        }
                    } label: {
                        Label("Delete expense", systemImage: "minus.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                }
            ExpenseCard(card: $card, workDay: $workDay, isInputActive: isInputActive)
        }
    }
    
    func calculateTotal(normal: Double, overtime: Double) -> String {
        let calculation = normal + overtime
        let answer = String(calculation)
        return answer
    }
}

//struct Timecard_Previews: PreviewProvider {
//    static var previews: some View {
//        Timecard()
//    }
//}
