//
//  DailyDetailView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 8/12/2022.
//
import SwiftUI

struct DailyDetailView: View {
    
    enum Field {
        case jobNumber, jobCode, projectName, amount, comment
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController : DataController
    
    let employee : Employee

    
    @ObservedObject var cards: Cards
    @Binding var weekArray: [String]
    @Binding var workDay: String

    
    @State private var card = [Card]()
    @FocusState var isInputActive: Field?

    @State private var showingAlert = false
    @State private var showExpenses = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section {
                        Picker("Day", selection: $workDay) {
                            ForEach(weekArray, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                        Timecard(card: $card, workDay: $workDay, isInputActive: $isInputActive, showExpenses: $showExpenses)
                }
                .navigationBarTitle("Add a daily timecard")
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            self.presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Dismiss")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            saveButton()
                        } label: {
                            Text("Save")
                        }
                    }
                }
                VStack {
                    Spacer()
                    
                    HStack {
                         Spacer()
                        
                        Button {
                            onAdd()
                        } label: {
                            Text("+")
                                .font(.system(.largeTitle))
                                .frame(width: 40, height: 35)
                                .foregroundColor(Color.white)
                                .padding(.bottom, 7)
                        }
                        .background(Color.blue.opacity(0.6))
                        .cornerRadius(38.5)
                        .padding()
                        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
                    }
                }
            }
        }
    }
    
    func onAdd() {
            card.append(Card(
                department: "31",
                jobNumber: "",
                jobCode: "9999",
                jobName: "",
                hours: 0.0,
                overtime: 0.0,
                day: $workDay.wrappedValue,
                expenses: []))
    }
    
    func saveButton() {

        for i in $card {
                let item = Card(
                    department: i.department.wrappedValue,
                    jobNumber: i.jobNumber.wrappedValue,
                    jobCode: i.jobCode.wrappedValue,
                    jobName: i.jobName.wrappedValue,
                    hours: i.hours.wrappedValue,
                    overtime: i.overtime.wrappedValue,
                    day: $workDay.wrappedValue,
                    expenses: i.expenses.wrappedValue)
                cards.items.append(item)
            }
            self.presentationMode.wrappedValue.dismiss()
        }
    
//        func deleteEntry() {
//            $card.wrappedValue.removeLast()
//        }
    
    }
    
    //struct DailyDetailView_Previews: PreviewProvider {
    //    static var previews: some View {
    //        DailyDetailView()
    //    }
    //}
