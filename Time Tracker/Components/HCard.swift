//
//  HCard.swift
//  Time Tracker
//
//  Created by Mark McKeon on 13/12/2022.
//

import SwiftUI

struct HCard: View {
    
    var card: Timesheet

    
    var body: some View {
        VStack{
            Text(card.projectName ?? "")
                .fontWeight(.bold)
        HStack {
            Text("Dept:   \(card.department ?? "")")
                .padding(.horizontal, 10)
            Text("Project: \(card.projectNumber ?? "")")
                .padding(.horizontal, 10)
            Text("Job Code: \(card.jobCode ?? "")")
                .padding(.horizontal, 10)

        }
        .padding(10)
                HStack {
                    Text("\(card.hours.formatted()) normal")
                        .padding(.horizontal, 10)
                    Text("\(card.overtime.formatted()) overtime")
                        .padding(.horizontal, 10)
                }
            }
    }
}

//struct HCard_Previews: PreviewProvider {
//    static var previews: some View {
//        HCard()
//    }
//}
