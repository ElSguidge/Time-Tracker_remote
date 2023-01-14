//
//  AddTimeCardView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 8/12/2022.
//



import SwiftUI
import UIKit
import MessageUI



@MainActor
struct AddTimeCardView: View {
    
    enum ActiveAlertTimecard {
        case first, second, third, fourth, fifth, zero, emailSent, emailSaved, emailFailed, emailCancelled, emailError
    }
    
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var dataController : DataController
    @Environment(\.managedObjectContext) var moc
    
    let employee : Employee
    var timesheets : [Timesheet]
    var weeks : [Week]
    var workExpenses: [WorkExpense]
    
    
    var filteredArray: [Timesheet] {
        
        return timesheets.filter { dateStrings(for: $0.weekEnding!) == selectedTemplate }.sorted { $0.day! < $1.day! }
    }
    
    @ObservedObject var cards = Cards()
    
    @State private var temp = Set<String>()
    @State private var showAlert : Bool = false
    @State private var activeAlert: ActiveAlertTimecard = .zero
    @State private var showingSaveButton = false
    @State private var showingBottomSheet = false
    @State private var weekEnding = Date.now
    @State private var weekArray : [String] = []
    @State private var workDay = ""
    @State private var datePickerId: Int = 0
    @State private var timesheetSubmittedConfirmation: Bool = false
    
    @State private var pdfSent = false
    @Binding var result: Result<MFMailComposeResult, Error>?
    @State private var sendEmailSheet = false
    
    
    @State private var selectedTemplate: String = ""
    @State private var showPicker: Bool = false
    
    var monday: Date {
        let calendar = Calendar(identifier: .gregorian)
        let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear,.weekOfYear], from: Date()))
        let monday = calendar.date(byAdding: .day, value: 1, to: sunday ?? Date())
        return monday!
    }
    
    
    var checkDay: Bool {
        let day = weekEnding
        let _ = Calendar.current
        let df = DateFormatter()
        df.dateStyle = .full
        let formattedDate = df.string(from: day)
        if formattedDate.hasPrefix("Monday") {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        NavigationStack {
            
            Form {
                
                DatePickerView
                
                
                
                if temp.count >= 2 && showPicker == false {
                    Section {
                        Button {
                            selectedTemplate = ""
                            self.sendEmail()
//                            activeAlert = .emailSent
                        } label: {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(Color.accentColor)
                                    .padding(7)
                                Text("Submit")
                            }
                        }
                        ShareLink("Share", item: render())
                        
                        Button {
                            saveAlert()
                        }
                    label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(Color.accentColor)
                                .padding(7)
                            Text("Save")
                        }
                    }
                        
                    }
                }
                
                
                if weekArray.isEmpty == false && showPicker == false {
                    
                    SavedWeeklyCard(employee: employee, timesheets: timesheets, weeks: weeks, showPicker: $showPicker, selectedTemplate: $selectedTemplate)
                    
                    CardTile
                    
                        .onChange(of: cards.items) { newValue in
                            showSaveButton()
                        }
                    
                    TotalsCard(cards: cards)
                    
                }
                else if weekArray.isEmpty == false && showPicker == true {
                    
                    SavedWeeklyCard(employee: employee, timesheets: timesheets, weeks: weeks, showPicker: $showPicker, selectedTemplate: $selectedTemplate)
                    
                    SavedCardTile
                }
                
            }
            .alert(isPresented: $showAlert) {
                switch activeAlert {
                case .first:
                    return Alert(title: Text("Weekending must be a monday."), message: Text("Please choose a Monday for the pay week ending date."), dismissButton: .default(Text("OK")))
                case .second:
                    return Alert(title: Text("Woops!"), message: Text("You have already submitted a timesheet for that week! Please choose another payweek date."), dismissButton: .default(Text("OK")))
                case .third:
                    return Alert(title: Text("Saved!"), message: Text("Timesheet saved on \(Date())"), dismissButton: .default(Text("OK")) {
                        cards.items.removeAll()
                        weekArray = []
                        self.presentation.wrappedValue.dismiss()
                    })
                case .fourth:
                    return Alert(title: Text("Have you submitted your timesheet?"), message: Text("Please confirm you have submitted your timesheet before saving. Otherwise proceed with saving only."), primaryButton: .default(Text("Confirm")) {
                        saveButton()
                    }, secondaryButton: .cancel())
                case .fifth:
                    return Alert(title: Text("Timesheet submitted."), message: Text("Timesheet submitted successfully on \(Date.now)"), dismissButton: .default(Text("OK")) {
                        cards.items.removeAll()
                        weekArray = []
                        self.presentation.wrappedValue.dismiss()
                    })
                case .zero:
                    return Alert(title: Text("Incorrect data"), dismissButton: .default(Text("OK")))
                    
                case .emailSent:
                        return Alert(title: Text("Success"), message: Text("Timecard succesfully submitted.."), dismissButton: .default(Text("OK")))
                    
                case .emailFailed:
                        return Alert(title: Text("Failed"), message: Text("Failed to send to recipient. Could not submit."), dismissButton: .default(Text("OK")))
                    
                case .emailCancelled:
                        return Alert(title: Text("Cancelled"), message: Text("Timesheet submittal cancelled."), dismissButton: .default(Text("OK")))
                    
                case .emailSaved:
                        return Alert(title: Text("Email Saved"), message: Text("Saved to drafts folder in your mail server."), dismissButton: .default(Text("OK")))
                    
                case .emailError:
                    return Alert(title: Text("Error"), message: Text("Unknown Error sending email."), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Add a new timesheet")
            .sheet(isPresented: $showingBottomSheet, content: {
                DailyDetailView(employee: self.employee, cards: cards, weekArray: $weekArray, workDay: $workDay)
            })
            .sheet(isPresented: $sendEmailSheet) {
                if selectedTemplate == "" {
                    let url = render()
                    MailViewModel(activeAlert: $activeAlert, showAlert: $showAlert, pdfAttachment: url, result: $result, newSubject: "\(employee.name ?? "") timesheet week ending \(String(describing: weekArray.last!))", newMsgBody: "Hi, \n Please find my timesheet attached for the week ending \(String(describing: weekArray.last!)).")

                } else  {
                    let url2 = renderSaved()
                    MailViewModel(activeAlert: $activeAlert, showAlert: $showAlert, pdfAttachment: url2, result: $result, newSubject: "\(employee.name ?? "") timesheet week ending \(String(describing: weekArray.last!))", newMsgBody: "Hi, \n Please find my timesheet attached for the week ending \(String(describing: weekArray.last!)).")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Dismiss")
                    }
                }
            }
        }
    }
    var CardTile: some View {
        Section {
            List {
                ForEach(weekArray.indices, id:\.self) { day in
                    Button(self.weekArray[day]) {
                        showingBottomSheet = true
                        workDay = self.weekArray[day]
                    }
                    ForEach(cards.items) { index in
                        if self.weekArray[day] == index.day {
                            NavigationLink {
                                TimecardEditView(card: index, items: self.cards)
                            } label: {
                                VStack {
                                    Spacer()
                                    
                                    HStack {
                                        Text(index.jobNumber)
                                        Text(index.jobCode.uppercased())
                                        Text(index.jobName.uppercased())
                                        Text("\(index.hours.formatted()) hours".uppercased())
                                        Text("\(index.overtime.formatted()) O/T".uppercased())
                                    }
                                    Spacer()
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .listRowBackground(Color.green.opacity(0.3))
                            }
                        }
                        
                    }
                }
                .onDelete { idx in
                    let idsToDelete = idx.map { cards.items[$0].id }
                    withAnimation {
                        deleteEntry(idsToDelete)
                    }
                }
            }
        }
    }
    var SavedCardTile: some View {
        
        List {
            if selectedTemplate != "" {
                Button {
                    sendEmail()

                } label: {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(Color.accentColor)
                            .padding(7)
                        Text("Submit")
                    }
                }
                
                ShareLink("Share", item: renderSaved())
                
                ForEach(0..<weekArray.count, id: \.self) { i in
                    let weekEndingDay = weekArray[i]
                    let day = weekEndingDay.components(separatedBy: " ").first ?? ""
                    Section(header: Text(weekArray[i])) {
                        ForEach(filteredArray) { index in
                            if let timesheetWeekEnding = index.day,
                               let firstWord = timesheetWeekEnding.components(separatedBy: " ").first,
                               firstWord == day {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Text("Dep: \(index.department ?? "")")
                                        Text(index.projectNumber ?? "")
                                        Text(index.jobCode?.uppercased() ?? "")
                                        Text(index.projectName?.uppercased() ?? "")
                                        Text("\(index.hours.formatted()) hrs".uppercased())
                                        Text("\(index.overtime.formatted()) O/T".uppercased())
                                    }
                                    Spacer()
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var DatePickerView: some View {
        Section (header: Text("Select Week Ending"), footer: Text("NOTE: Payweek ending each Monday")) {
            ZStack {
                DatePicker("Week ending date", selection: $weekEnding,
                           in: monday...,
                           displayedComponents: [.date])
                .id(datePickerId)
                .onChange(of: weekEnding){ _ in
                    _ = generateDates()
                }
            }
        }
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            self.sendEmailSheet = true
        } else {
            print("error in sending email")
        }
    }
    
    
    func dateStrings(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.setLocalizedDateFormatFromTemplate("y-MM-dd")
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func deleteEntry(_ idsToDelete: [UUID]) {
        cards.items.removeAll() { item in
            idsToDelete.contains(item.id)
        }
    }
    
    func generateDates() -> [String] {
        
        weekArray = []
        datePickerId += 1
        cards.items.removeAll()
        let anchor = weekEnding
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        
        if checkDay {
            
            for dayOffset in -6...0 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: anchor) {
                    weekArray.append(formatter.string(from: date))
                }
                if weeks.isEmpty == false {
                    for week in weeks {
                        let changeDate = formatter.string(from: week.weekEnding!)
                        let selectedDay = formatter.string(from: anchor)
                        if checkDay && selectedDay == changeDate {
                            weekArray = []
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                weekArray = []
                                self.showAlert = true
                                self.activeAlert = .second
                            }
                        }
                    }
                }
            }
            
            return weekArray // weeking is a monday and returns weekarray with dates
            
        } else {
            weekArray = []
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.showAlert = true
                self.activeAlert = .first
            }
        }
        return weekArray // returns empty array
    }
    
    func showSaveButton() {
        for days in cards.items {
            temp.insert(days.day)
            if temp.count >= 5 {
                showingSaveButton = true
            }
            showingSaveButton = false
        }
    }
    
    func saveAlert() {
        self.showAlert = true
        self.activeAlert = .fourth
    }
    
    func saveButton() {
        
        let newWeek = Week(context: dataController.container.viewContext)
        newWeek.weekEnding = self.weekEnding
        newWeek.submitted = self.timesheetSubmittedConfirmation
        newWeek.totalHoursNormal = cards.addNormalHours()
        newWeek.totalHoursOvertime = cards.addOvertimeHours()
        newWeek.totalHours = cards.addTotalHours()
        newWeek.date = Date()
        newWeek.id = UUID()
        newWeek.employees = self.employee
        
        for timecards in cards.items {
            
            let timecard = Timesheet(context: dataController.container.viewContext)
            timecard.id = UUID()
            timecard.jobCode = timecards.jobCode
            timecard.projectName = timecards.jobName
            timecard.hours = timecards.hours
            timecard.overtime = timecards.overtime
            timecard.employees = self.employee
            timecard.department = timecards.department
            timecard.projectNumber = timecards.jobNumber
            timecard.date = Date()
            timecard.day = timecards.day
            timecard.weekEnding = self.weekEnding
            
            for expense in timecards.expenses {
                
                let workExpense = WorkExpense(context: dataController.container.viewContext)
                if expense.image != nil {
                    let data = expense.image!.jpegData(compressionQuality: 0.1)
                    workExpense.employees = self.employee
                    workExpense.projectNumber = timecards.jobNumber
                    workExpense.expenseType = expense.expenseType
                    workExpense.date = timecards.day
                    workExpense.amount = expense.amount
                    workExpense.image = data
                    workExpense.comment = expense.comment
                    workExpense.weekEnding = self.weekEnding
                } else {
                    workExpense.expenseType = expense.expenseType
                    workExpense.projectNumber = timecards.jobNumber
                    workExpense.weekEnding = self.weekEnding
                    workExpense.date = timecards.day
                    workExpense.amount = expense.amount
                    workExpense.image = nil
                    workExpense.comment = expense.comment
                }

            }
        }
        dataController.save()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showAlert = true
            self.activeAlert = .third
        }
    }
    
    func render() -> URL {
        let url = URL.documentsDirectory.appending(path: "\(UUID()).pdf")
        let renderer = ImageRenderer(content: PdfView(weekArray: $weekArray, cards: cards, employee: self.employee))
        
        renderer.render { size, context in
            // 4: Tell SwiftUI our PDF should be the same size as the views we're rendering
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            // 5: Create the CGContext for our PDF pages
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }
            
            
            
            // 6: Start a new PDF page
            pdf.beginPDFPage(nil)
            
            // 7: Render the SwiftUI view data onto the page
            context(pdf)
            
            // 8: End the page and close the file
            pdf.endPDFPage()
            pdf.closePDF()
            
        }

        return url
    }
    
    func renderSaved() -> URL {
        let url = URL.documentsDirectory.appending(path: "\(UUID()).pdf")
        let renderer = ImageRenderer(content: PDFViewSaved(weekArray: $weekArray, employee: self.employee, timesheet: filteredArray))
                
        print("renderSave: \(url)")
        renderer.render { size, context in
            // 4: Tell SwiftUI our PDF should be the same size as the views we're rendering
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            // 5: Create the CGContext for our PDF pages
            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }
            

            // 6: Start a new PDF page
            pdf.beginPDFPage(nil)
            
            // 7: Render the SwiftUI view data onto the page
            context(pdf)
            
            // 8: End the page and close the file
            pdf.endPDFPage()
            pdf.closePDF()
            
        }

        return url
    }
}

//struct AddTimeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddTimeCardView()
//    }
//}
