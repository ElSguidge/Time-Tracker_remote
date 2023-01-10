//
//  ContentView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 7/12/2022.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @EnvironmentObject var dataController : DataController
    
    let employees : FetchRequest<Employee>
    
    @State var showingAddEmployee : Bool = false
    

    init() {
        employees = FetchRequest<Employee>(entity: Employee.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Employee.date, ascending: false)])
        
    }
        var body: some View {
            NavigationStack {
                VStack {
                    Section {
                        List {
                            ForEach(employees.wrappedValue) { employee in
                                NavigationLink  {
                                    MainDetailView(employee: employee)
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(employee.name ?? "Anonymous")
                                            .font(.headline)
                                        Spacer()
                                        Text(employee.payrollNumber ?? "P12345")
                                            .font(.headline)
                                    }
                                    .padding()
                                }
                            }
                            .onDelete(perform: deleteEmployee)
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
                .navigationTitle("Employee")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            self.showingAddEmployee = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddEmployee) {
                    AddNewEmployeeView()
                }
            }
        }
        
        func deleteEmployee( at offsets : IndexSet) {
            for offset in offsets {
                let employee = employees.wrappedValue[offset]
                dataController.delete(employee)
            }
            dataController.save()
        }
    }

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
