//
//  PDFViewSaved.swift
//  Time Tracker
//
//  Created by Mark McKeon on 11/1/2023.
//

import SwiftUI

struct PDFViewSaved: View {
    @Binding var weekArray: [String]
    
    let employee : Employee
    var timesheet : [Timesheet]
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(.gray.opacity(0.4))
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Employee: \(employee.name ?? "")")
                    .fontWeight(.semibold)
                Text("Payroll No: \(employee.payrollNumber ?? "")")
                    .fontWeight(.semibold)
                if weekArray.isEmpty == false {
                    Text("Week ending: \(weekArray[6])")
                } else {
                    Text("Week ending: 01/01/1945")
                }
                Text("Date submitted: \(Date.now)")                    
                ForEach(0..<weekArray.count, id: \.self) { i in
                    let weekEndingDay = weekArray[i]
                    let day = weekEndingDay.components(separatedBy: " ").first ?? ""
                    Text(weekArray[i])
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                    ForEach(timesheet) { index in
                        if let timesheetWeekEnding = index.day,
                           let firstWord = timesheetWeekEnding.components(separatedBy: " ").first,
                           firstWord == day {
                        Text(index.projectName ?? "")
                            .fontWeight(.bold)
                        Text("Dept:  \(index.department ?? "")")
                        Text("Project: \(index.projectNumber ?? "")")
                        Text("Job code:  \(index.jobCode ?? "")")
                        Text("Normal hours: \(index.hours.formatted())")
                        Text("Overtime: \(index.overtime.formatted())")
                        
                        }
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
    }
}

