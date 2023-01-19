//
//  ExpenseCard.swift
//  Time Tracker
//
//  Created by Mark McKeon on 24/12/2022.
//

import SwiftUI

struct ExpenseCard: View {
    
    @Binding var expense: Expense
    @Binding var workDay: String
    var isInputActive: FocusState<DailyDetailView.Field?>.Binding
    @Binding var jobNumber: String
    
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isImagePickerDisplayed = false
    @State private var showingOptions = false
    
    let types = ["Parking", "Materials", "Other"]
    
    var body: some View {
        
        Picker("Type", selection: self.$expense.expenseType) {
            ForEach(types, id:\.self) {
                Text($0)
            }
            .padding(20)
        }
        Text("\(workDay)")
        TextField("Job Number", text: self.$jobNumber)
            .focused(isInputActive, equals: .jobNumber)
        
        TextField("Amount", value: self.$expense.amount, format: .currency(code: Locale.current.currency?.identifier ?? "AUD"))
            .keyboardType(.decimalPad)
            .focused(isInputActive, equals: .amount)
        
        Button {
            withAnimation {
                self.showingOptions = true
            }
            
        } label: {
            Label("Add image", systemImage: "photo")
        }
        
        .confirmationDialog("", isPresented: self.$showingOptions, titleVisibility: .hidden) {
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
            ImagePickerView(selectedImage: self.$expense.image, sourceType:self.sourceType)
        }
        
        if self.$expense.image.wrappedValue != nil {
            withAnimation {
                Image(uiImage: self.$expense.image.wrappedValue!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
            }
        }
        
        TextField("Comment", text: self.$expense.comment, axis: .vertical) .lineLimit(4, reservesSpace: true)
            .focused(isInputActive, equals: .comment)
    }
}

//struct ExpenseCard_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpenseCard()
//    }
//}
