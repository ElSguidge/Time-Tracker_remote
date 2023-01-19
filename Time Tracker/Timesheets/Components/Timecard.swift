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
    
    @Binding var showExpenses: Bool
    
    let departments = ["31", "32", "56", "44"]
    let jobCodes = ["2647 - Public Holiday", "2466 - RDO", "2455 - Meeting", "2432 - Office"]
    
    var body: some View {
        ForEach($card.indices, id: \.self) { item in
            
            Section {
                HStack {
                    Text("Delete")
                    Spacer()
                    Button {
                        withAnimation {
                            if self.$card.indices.contains(item) {
                                dismissKeyboardAndDeleteCard(at: item)
                            }
                        }
                        
                    } label: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                    }
                    
                }
                .listRowBackground(Color.red.opacity(0.3))
                
                Picker("Department", selection: self.$card[item].department) {
                    ForEach(departments, id: \.self) {
                        Text($0)
                    }
                }
                TextField("Job Number", text: self.$card[item].jobNumber)
                    .focused(isInputActive, equals: .jobNumber)
                //
                TextField("Work Code (Enter 9999 for generic codes)", text: self.$card[item].jobCode)
                    .focused(isInputActive, equals: .jobCode)
                
                
                if self.$card[item].jobCode.wrappedValue == "9999" {
                    
                    Picker("Work Code", selection: self.$card[item].jobCode) {
                        ForEach(jobCodes, id: \.self) {
                            Text($0)
                        }
                    }
                }
                TextField("Project name", text: self.$card[item].jobName)
                    .focused(isInputActive, equals: .projectName)
                Stepper("\(self.$card[item].hours.wrappedValue.formatted()) Normal Hours", value: self.$card[item].hours, in: 0...16, step: 0.5)
                Stepper("\(self.$card[item].overtime.wrappedValue.formatted()) Overtime Hours", value: self.$card[item].overtime, in: 0...16, step: 0.5)
                Text("Total Hours: \(calculateTotal(normal: self.$card[item].hours.wrappedValue, overtime: self.$card[item].overtime.wrappedValue))")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .listRowBackground(Color.green.opacity(0.5))
                
                Button {
                    self.$card[item].wrappedValue.addExpenses()
                    self.showExpenses = true
                    
                } label: {
                    Label("Add expenses", systemImage: "plus.circle.fill")
                }
            }
            
            List($card[item].expenses) { $expense in
                ExpenseCard(expense: $expense, workDay: self.$workDay, isInputActive: isInputActive, jobNumber: $card[item].jobNumber)
            }
        }
    }
    func dismissKeyboardAndDeleteCard(at index: Int) {
        UIApplication.shared.keyWindow?.endEditing(true)
        deleteCard(at: index)
    }
    
    func deleteCard(at index: Int) {
        if self.card.indices.contains(index) {
            card.remove(at: index)
        }
    }
    
    func calculateTotal(normal: Double, overtime: Double) -> String {
        let calculation = normal + overtime
        let answer = String(calculation)
        return answer
    }
}


extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
        // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
        // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
        // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}
//struct Timecard_Previews: PreviewProvider {
//    static var previews: some View {
//        Timecard()
//    }
//}
