//
//  PdfView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 23/12/2022.
//

import SwiftUI

struct PdfView: View {
    
    @Binding var weekArray: [String]
    @ObservedObject var cards = Cards()
    
    let employee : Employee
    
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
                ForEach(weekArray, id: \.self) { day in
                    Text(day)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                    ForEach(cards.items) { index in
                        if index.day == day {
                        Text(index.jobName)
                            .fontWeight(.bold)
                        Text("Dept:  \(index.department)")
                        Text("Project: \(index.jobNumber)")
                        Text("Job code:  \(index.jobCode)")
                        Text("Normal hours: \(index.hours.formatted())")
                        Text("Overtime: \(index.overtime.formatted())")
                        
                            ForEach(index.expenses) { exp in
                                HStack {
                                    Text("\(exp.expenseType):")
                                    Text("$\(exp.amount.formatted())")
                                }
                                if exp.image != nil {
                                    Image(uiImage: exp.image!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 180, height: 180)
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
    }
}

//struct PdfView_Previews: PreviewProvider {
//    static var previews: some View {
//        PdfView()
//    }
//}
