//
//  MailView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 12/1/2023.
//

import Foundation
import SwiftUI
import UIKit
import MessageUI

struct MailViewModel: UIViewControllerRepresentable {
    
    @Binding var activeAlert: AddTimeCardView.ActiveAlertTimecard
    @Binding var showAlert: Bool

    let pdfAttachment: URL
    
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    let newSubject : String
    let newMsgBody : String
//    @Binding var activeAlert: ActiveAlertTimecard
//    @Binding var showAlert: Bool
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        
        @Binding var activeAlert: AddTimeCardView.ActiveAlertTimecard
        @Binding var showAlert: Bool
        @Binding var presentation : PresentationMode
        @Binding var result : Result<MFMailComposeResult, Error>?
        
        init(
            activeAlert: Binding<AddTimeCardView.ActiveAlertTimecard>,
            showAlert: Binding<Bool>,
            presentation: Binding<PresentationMode>,
            result: Binding<Result<MFMailComposeResult, Error>?>) {
                
            _activeAlert = activeAlert
            _showAlert = showAlert
            _presentation = presentation
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
            
            if !showAlert {
                switch result {
                case .sent:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showAlert = true
                        self.activeAlert = .emailSent
                    }
                case .saved:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showAlert = true
                        self.activeAlert = .emailSaved
                    }
                case .failed:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showAlert = true
                        self.activeAlert = .emailFailed
                    }
                case .cancelled:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showAlert = true
                        self.activeAlert = .emailCancelled
                    }
                default:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.showAlert = true
                        self.activeAlert = .emailError
                    }
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(activeAlert: $activeAlert, showAlert: $showAlert, presentation: presentation, result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailViewModel>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
                vc.mailComposeDelegate = context.coordinator
                vc.setToRecipients(["mark.mckeon79@gmail.com"])
                vc.setSubject(newSubject)
                vc.setMessageBody(newMsgBody, isHTML: false)
                do {
                    let pdfData = try Data(contentsOf: pdfAttachment)
                    vc.addAttachmentData(pdfData, mimeType: "application/pdf", fileName: pdfAttachment.lastPathComponent)
                } catch {
                    // handle error
                }
                return vc
            }
    
    func addAttachment(url: URL, vc: MFMailComposeViewController) {
        let data = try! Data(contentsOf: url)
        addAttachmentData(data: data, mimeType: "application/pdf", fileName: "Timesheet.pdf", vc: vc)
    }

    func addAttachmentData(data: Data, mimeType: String, fileName: String, vc: MFMailComposeViewController) {
        vc.addAttachmentData(data, mimeType: mimeType, fileName: fileName)
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailViewModel>) {
        
    }
}
