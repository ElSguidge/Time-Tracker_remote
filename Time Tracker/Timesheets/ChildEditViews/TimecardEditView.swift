//
//  TimecardEditView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 12/12/2022.
//

import SwiftUI

struct TimecardEditView: View {
    @Environment(\.presentationMode) var presentationMode
    var card: Card
    var items: Cards
    
    @State private var department = "31"
    @State private var jobNumber = ""
    @State private var jobCode = "9999"
    @State private var jobName = ""
    @State private var hours = 0.0
    @State private var overtime = 0.0
    @State private var day = ""
    @State private var expenses = [Expense]()
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isImagePickerDisplayed = false
    @State private var showingOptions = false
    
    @FocusState private var isInputActive: Bool

    
    var expenseType = ""
    var amount = 0.0
    var image: UIImage?
    var comment = ""
    
    
    let types = ["Parking", "Materials", "Other"]
    let departments = ["31", "32", "56", "44"]
    let jobCodes = ["2647 - Public Holiday", "2466 - RDO", "2455 - Meeting", "2432 - Office"]
    

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("\(day)")
                }
                    Section {
                        Picker("Department", selection: $department) {
                            ForEach(departments, id: \.self) {
                                Text($0)
                            }
                        }
                        TextField("Job Number", text: $jobNumber)
                            .focused($isInputActive)
                        TextField("Work Code (Enter 9999 for generic codes)", text: $jobCode)
                            .focused($isInputActive)
                            Section {
                                Picker("Work Code", selection: $jobCode) {
                                    ForEach(jobCodes, id: \.self) {
                                        Text($0)
                                    }
                                }
                            }
                        TextField("Project name", text: $jobName)
                            .focused($isInputActive)
                        Stepper("\(hours.formatted()) Normal Hours", value: $hours, in: 0...16, step: 0.5)
                        Stepper("\(overtime.formatted()) Overtime Hours", value: $overtime, in: 0...16, step: 0.5)
                        Text("Total Hours: \(calculateTotal(normal: hours, overtime: overtime))")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .listRowBackground(Color.green.opacity(0.7))
                    }
                    ForEach($expenses) { index in
                        Section(header: Text("Expense")) {
                        Picker("Type", selection: index.expenseType) {
                                ForEach(types, id:\.self) {
                                    Text($0)
                                }
                                .padding(20)
                            }
                            TextField("Job Number", text: $jobNumber)
                                TextField("Amount", value: index.amount, format: .currency(code: Locale.current.currency?.identifier ?? "AUD"))
                                    .focused($isInputActive)
                                    .keyboardType(.decimalPad)
                                Button {
                                    withAnimation {
                                        showingOptions = true
                                    }
                                } label: {
                                    Label("Edit image", systemImage: "photo")
                                }
                                .confirmationDialog("", isPresented: $showingOptions, titleVisibility: .hidden) {
                                    Button("Take photo") {
                                        withAnimation {
                                            self.sourceType = .camera
                                            self.isImagePickerDisplayed.toggle()
                                        }
                                    }
                                    Button("Choose photo") {
                                        withAnimation {
                                            self.sourceType = .photoLibrary
                                            self.isImagePickerDisplayed.toggle()
                                        }
                                    }
                                }
                                .sheet(isPresented: self.$isImagePickerDisplayed) {
                                    ImagePickerView(selectedImage: index.image, sourceType:self.sourceType)
                                }
                            if index.image.wrappedValue != nil {
                                Image(uiImage: index.image.wrappedValue!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 300, height: 300)
                            }
                                TextField("Comment", text: index.comment, axis: .vertical) .lineLimit(4, reservesSpace: true)
                                .focused($isInputActive)
                    }
                }
            }
            .navigationTitle("Edit timecard")
            
            .onAppear{
                self.jobName = self.card.jobName
                self.department = self.card.department
                self.day = self.card.day
                self.jobCode = self.card.jobCode
                self.hours = self.card.hours
                self.overtime = self.card.overtime
                self.jobNumber = self.card.jobNumber
                self.expenses = self.card.expenses
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.items.updateTimecard(for: self.card, to: self.department, to: self.jobCode, to: self.jobNumber, to: self.jobName, to: self.hours, to: self.overtime, to: self.day, to: self.expenses)
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Save")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Dismiss")
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isInputActive = false
                        }
                }
            }
        }
    }
    func calculateTotal(normal: Double, overtime: Double) -> String {
        let calculation = normal + overtime
        let answer = String(calculation)
        return answer
    }
}

//struct TimecardEditView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimecardEditView()
//    }
//}
