//
//  TimecardModel.swift
//  Time Tracker
//
//  Created by Mark McKeon on 12/12/2022.
//

import Foundation
import SwiftUI


struct Card: Identifiable, Equatable {
    
    var id = UUID()
    var department: String
    var jobNumber: String
    var jobCode: String
    var jobName: String
    var hours = 0.0
    var overtime = 0.0
    var day: String
    var expenses: [Expense]
    
    mutating func addExpenses() {
        expenses.append(Expense(expenseType: "Parking", amount: 0.0, comment: ""))
    }
    
    mutating func deleteExpenses() {
        expenses.removeLast()
    }
}

struct Expense: Identifiable, Equatable {
    
    var id = UUID()
    var expenseType: String
    var amount = 0.0
    var image: UIImage?
    var comment: String
    
}


class Cards: ObservableObject {
    @Published var items = [Card]()
    
    func updateTimecard(for card: Card,
                        to newDepartment: String,
                        to newJobCode: String,
                        to newJobNumber: String,
                        to newJobName: String,
                        to newHours: Double?,
                        to newOvertime: Double?,
                        to newDay: String,
                        to newExpense: [Expense]
    ) {
        if let index = items.firstIndex(where: { $0.id == card.id}) {
            items[index].jobNumber = newJobNumber
            items[index].jobName = newJobName
            items[index].overtime = newOvertime ?? 0.0
            items[index].jobCode = newJobCode
            items[index].day = newDay
            items[index].department = newDepartment
            items[index].hours = newHours ?? 8.0
            items[index].expenses = newExpense
        }
    }
    
    func addNormalHours() -> String {
        var result = 0.0
       for item in items {
           result += item.hours
       }
       
       return String(result.formatted())
   }
   func addOvertimeHours() -> String {
       var result = 0.0
      for item in items {
          result += item.overtime
      }
      
      return String(result.formatted())
  }
   func addTotalHours() -> String {
       var result = 0.0
       for item in items {
           result += item.hours + item.overtime
       }
       return String(result.formatted())
   }
   
   func calculateTotalExpenses() -> String {
       var result = 0.0
       for item in items {
           for item in item.expenses {
               result += item.amount
           }
       }
       return String(result.formatted())
   }
}
