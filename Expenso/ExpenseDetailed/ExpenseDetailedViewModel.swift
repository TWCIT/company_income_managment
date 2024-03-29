//
//  ExpenseDetailedViewModel.swift
//  Expenso
//
//  Created by Sameer Nawaz on 31/01/21.
//

import UIKit
import CoreData

class ExpenseDetailedViewModel: ObservableObject {
    
    @Published var expenseObj: ExpenseCD
    
    @Published var alertMsg = String()
    @Published var showAlert = false
    @Published var closePresenter = false
    
    init(expenseObj: ExpenseCD) {
        self.expenseObj = expenseObj
    }
    
    func deleteNote(managedObjectContext: NSManagedObjectContext) {
        managedObjectContext.delete(expenseObj)
        do {
            try managedObjectContext.save(); closePresenter = true
        } catch { alertMsg = "\(error)"; showAlert = true }
    }
    
    func shareNote() {
        let shareStr = """
        Tytuł: \(expenseObj.title ?? "")
        Kwota: \(UserDefaults.standard.string(forKey: UD_EXPENSE_CURRENCY) ?? "")\(expenseObj.amount)
        Typ transakcji: \(expenseObj.type == TRANS_TYPE_INCOME ? "Przychód" : "Wydatek")
        Kategoria: \(getTransTagTitle(transTag: expenseObj.tag ?? ""))
        Data: \(getDateFormatter(date: expenseObj.occuredOn, format: "EEEE, dd MMM hh:mm a"))
        Notatka: \(expenseObj.note ?? "")
        
        \(SHARED_FROM_EXPENSO)
        """
        let av = UIActivityViewController(activityItems: [shareStr], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
}
