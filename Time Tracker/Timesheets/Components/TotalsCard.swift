//
//  TotalsCard.swift
//  Time Tracker
//
//  Created by Mark McKeon on 24/12/2022.
//

import SwiftUI

struct TotalsCard: View {
    
    @ObservedObject var cards = Cards()
    
    var body: some View {
        Section {
            Text("Total Hours Normal:   \(cards.addNormalHours())")
            Text("Total Hours Overtime:  \(cards.addOvertimeHours())")
            Text("Total Expenses:  $\(cards.calculateTotalExpenses())")
            Text("Total hours: \(cards.addTotalHours())")
                .foregroundColor(.black)
                .fontWeight(.bold)
                .listRowBackground(Color.green.opacity(0.7))
        }
    }
}

//struct TotalsCard_Previews: PreviewProvider {
//    static var previews: some View {
//        TotalsCard()
//    }
//}
