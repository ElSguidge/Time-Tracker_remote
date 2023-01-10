//
//  AddNewEmployeeView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 8/12/2022.
//

import SwiftUI

enum ActiveAlertEmployee {
    case first, second, zero
}

struct AddNewEmployeeView: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController : DataController
    
    @State private var name: String = ""
    @State private var payrollNumber : String = ""
    
    @State private var showAlert : Bool = false
    @State private var activeAlert : ActiveAlertEmployee = .zero
    
    var body: some View {
        NavigationStack {
            Form {
                Section (header: Text("Name")) {
                    TextField("Enter name", text: $name)
                        .keyboardType(.default)
                }
                Section (header: Text("Payroll Number")) {
                    TextField("Enter payroll number", text: $payrollNumber)
                }
            }
            .navigationTitle("Add new employee")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.presentation.wrappedValue.dismiss()
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
            .alert(isPresented: $showAlert) {
                switch activeAlert {
                case.first:
                    return Alert(title: Text("Name is empty"), message: Text("enter name"), dismissButton: .default(Text("OK")))
                case .second:
                    return Alert(title: Text("Payroll number not entered"), message: Text("Enter payroll number"), dismissButton: .default(Text("OK")))
                case .zero:
                    return Alert(title: Text("Incorrect data"), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    func saveButton() {
        
        if self.name.isEmpty {
            self.activeAlert = .first
            self.showAlert = true
        }
        else if self.payrollNumber.isEmpty {
            self.activeAlert = .second
            self.showAlert = true
            
        } else {
            let employee = Employee(context: dataController.container.viewContext)
            
            employee.id = UUID()
            employee.date = Date()
            employee.name = self.name
            employee.payrollNumber = self.payrollNumber
            
            dataController.save()
            
            self.presentation.wrappedValue.dismiss()
        }
    }
}

struct AddNewEmployeeView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewEmployeeView()
    }
}
