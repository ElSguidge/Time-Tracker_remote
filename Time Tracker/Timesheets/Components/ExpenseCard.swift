//
//  ExpenseCard.swift
//  Time Tracker
//
//  Created by Mark McKeon on 24/12/2022.
//

import SwiftUI

struct ExpenseCard: View {
    
    @Binding var card: [Card]
    @Binding var workDay: String
    var isInputActive: FocusState<DailyDetailView.Field?>.Binding

    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isImagePickerDisplayed = false
    @State private var showingOptions = false
    
    let types = ["Parking", "Materials", "Other"]
    
    var body: some View {
        ForEach($card) { item in
            ForEach(item.expenses) { expense in
                if item.expenses.isEmpty == false {
                    Section(header: Text("New expense")) {
                        Picker("Type", selection: expense.expenseType) {
                            ForEach(types, id:\.self) {
                                Text($0)
                            }
                            .padding(20)
                        }
                        Text("\(workDay)")
                        TextField("Job Number", text: item.jobNumber)
                            .focused(isInputActive, equals: .jobNumber)
                        
                        TextField("Amount", value: expense.amount, format: .currency(code: Locale.current.currency?.identifier ?? "AUD"))
                            .keyboardType(.decimalPad)
                            .focused(isInputActive, equals: .amount)

                        Button {
                            withAnimation {
                                self.showingOptions = true
                            }

                        } label: {
                            Label("Add image", systemImage: "photo")
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
                            ImagePickerView(selectedImage: expense.image, sourceType:self.sourceType)
                        }

                        if expense.image.wrappedValue != nil {
                            withAnimation {
                                Image(uiImage: expense.image.wrappedValue!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 300, height: 300)
                            }
                        }

                        TextField("Comment", text: expense.comment, axis: .vertical) .lineLimit(4, reservesSpace: true)
                            .focused(isInputActive, equals: .comment)

                    }
                }
            }
        }
    }
}

//struct ExpenseCard_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpenseCard()
//    }
//}
