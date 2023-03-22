//
//  AddExpenseViewModel.swift
//  Expenso
//
//  Created by Sameer Nawaz on 31/01/21.
//

import UIKit
import CoreData

class AddExpenseViewModel: ObservableObject {
    
    var expenseObj: ExpenseCD?
    
    @Published var title = ""
    @Published var amount = ""
    @Published var amount2 = ""
    @Published var amount3 = ""
    @Published var occuredOn = Date()
    @Published var occuredTo = Date()
    @Published var note = ""
    @Published var name = ""
    @Published var typeTitle = "Income"
    @Published var tagTitle = getTransTagTitle(transTag: TRANS_TAG_TRANSPORT)
    @Published var showTypeDrop = false
    @Published var showTagDrop = false
    @Published var paidIs = false
    
    @Published var selectedType = TRANS_TYPE_INCOME
    @Published var selectedTag = TRANS_TAG_TRANSPORT
    @Published var expanseBuild: BuildCD? = nil
    @Published var expanseWorker: WorkerCD? = nil

    @Published var imageUpdated = false // When transaction edit, check if attachment is updated?
    @Published var imageAttached: UIImage? = nil
    
    @Published var alertMsg = String()
    @Published var showAlert = false
    @Published var closePresenter = false
    
    init(expenseObj: ExpenseCD? = nil) {
        
        self.expenseObj = expenseObj
        self.title = expenseObj?.title ?? ""
        if let expenseObj = expenseObj {
            self.amount = String(expenseObj.amount)
            self.amount2 = String(expenseObj.amount2)
            self.amount3 = String(expenseObj.amount3)

            self.typeTitle = expenseObj.type == TRANS_TYPE_INCOME ? "Income" : "Expense"
        } else {
            self.amount = ""
            self.amount2 = "1"
            self.amount3 = "0"
            self.typeTitle = "Income"
        }
        
        self.occuredOn = expenseObj?.occuredOn ?? Date()
        self.occuredTo = expenseObj?.occuredTo ?? Date()
        self.note = expenseObj?.note ?? ""
        self.tagTitle = getTransTagTitle(transTag: expenseObj?.tag ?? TRANS_TAG_TRANSPORT)
        self.selectedType = expenseObj?.type ?? TRANS_TYPE_INCOME
        self.selectedTag = expenseObj?.tag ?? TRANS_TAG_TRANSPORT
        self.paidIs = expenseObj?.paidIs ?? false
        self.name = expenseObj?.expanseWorker?.name ?? ""
        self.expanseWorker = expenseObj?.expanseWorker
        self.expanseBuild = expenseObj?.expanseBuild
        if let data = expenseObj?.imageAttached {
            self.imageAttached = UIImage(data: data)
        }
        
        
        AttachmentHandler.shared.imagePickedBlock = { [weak self] image in
            self?.imageUpdated = true
            self?.imageAttached = image
        }
    }
    
    func getButtText() -> String {
        if selectedType == TRANS_TYPE_INCOME { return "\(expenseObj == nil ? "Dodaj" : "Edytuj") przychód" }
        else if selectedType == TRANS_TYPE_EXPENSE { return "\(expenseObj == nil ? "Dodaj" : "Edytuj") wydatek" }
        else { return "\(expenseObj == nil ? "Dodaj" : "Edytuj") transakcję" }
    }
    
    func attachImage() { AttachmentHandler.shared.showAttachmentActionSheet() }
    
    func removeImage() { imageAttached = nil }
    
    func saveTransaction(managedObjectContext: NSManagedObjectContext) {
        var numb = Calendar.daysBetween(start: occuredOn, end: occuredTo)
        if Int(amount3) ?? -1 >= 0 {
            numb -= Int(amount3) ?? 0
        }
        for numb in 0...numb{
        let expense: ExpenseCD
        let titleStr = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let amountStr = amount.trimmingCharacters(in: .whitespacesAndNewlines)
            let amountStr2 = amount2.trimmingCharacters(in: .whitespacesAndNewlines)
            let amountStr3 = amount3.trimmingCharacters(in: .whitespacesAndNewlines)
        if titleStr.isEmpty || titleStr == "" {
            alertMsg = "Wpisz tytuł"; showAlert = true
            return
        }
        if amountStr.isEmpty || amountStr == "" {
            alertMsg = "Wpisz kwotę"; showAlert = true
            return
        }
            guard let amount3 = Int(amountStr3) else {
                alertMsg = "Wpisz w liczbie dni wolnych 0 jeśli takich danych zakres nie posiada"; showAlert = true
                return
            }
            guard let amount2 = Double(amountStr2) else {
                alertMsg = "Wpisz liczbę, nie litere lub inny znak specjalny"; showAlert = true
                return
            }
        guard let amount = Double(amountStr) else {
            alertMsg = "Wpisz liczbę, nie litere lub inny znak specjalny"; showAlert = true
            return
        }
        
        if expenseObj != nil {
            
            expense = expenseObj!
            
            if let image = imageAttached {
                if imageUpdated {
                    if let _ = expense.imageAttached {
                        // Delete Previous Image from CoreData
                    }
                    expense.imageAttached = image.jpegData(compressionQuality: 1.0)
                }
            } else {
                if let _ = expense.imageAttached {
                    // Delete Previous Image from CoreData
                }
                expense.imageAttached = nil
            }
            
        } else {
            expense = ExpenseCD(context: managedObjectContext)
            expense.createdAt = Date()
            if let image = imageAttached {
                expense.imageAttached = image.jpegData(compressionQuality: 1.0)
            }
        }
            
        expense.updatedAt = Date()
        expense.type = selectedType
        expense.title = titleStr
        expense.tag = selectedTag
            expense.occuredOn = occuredOn + Double(numb)
        expense.occuredTo = occuredTo
        expense.paidIs = paidIs
        expense.note = note
            expense.amount2 = amount2
            expense.amount3 = Int64(amount3)
        expense.expanseWorker = expanseWorker
        expense.expanseBuild = expanseBuild
            expense.amount = amount
            if(expense.expanseWorker != nil){
                let amount1 = ((expanseWorker?.amount ?? 1.0) * expense.amount2 )
                
                if (expense.amount == 0.0){
                    expense.amount = amount1
                }
                else{
                    expense.amount = amount
                }
            }
            
        do {
           // var numb = Calendar.numberOfDaysBetween(_from: Date, to: Date)
            
                
                try managedObjectContext.save()
            
            closePresenter = true
            
        } catch { alertMsg = "\(error)"; showAlert = true }
        }
    }
    
    func deleteTransaction(managedObjectContext: NSManagedObjectContext) {
        guard let expenseObj = expenseObj else { return }
        managedObjectContext.delete(expenseObj)
        do {
            try managedObjectContext.save(); closePresenter = true
        } catch { alertMsg = "\(error)"; showAlert = true }
    }
}
