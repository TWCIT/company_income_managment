//
//  WorkerDetailedViewModel.swift
//  Expenso
//
//  Created by Marek Wala on 25/04/2021.
//

import SwiftUI

class WorkerDetailedViewModel: ObservableObject {
    
    @Published var workerObj: WorkerCD
    
    @Published var alertMsg = String()
    @Published var showAlert = false
    @Published var closePresenter = false
    
    init(workerObj: WorkerCD) {
        self.workerObj = workerObj
    }
    
    func deleteNote(managedObjectContext: NSManagedObjectContext) {
        managedObjectContext.delete(workerObj)
        do {
            try managedObjectContext.save(); closePresenter = true
        } catch { alertMsg = "\(error)"; showAlert = true }
    }
    
    func shareNote() {
        let shareStr = """
        Imie: \(workerObj.name ?? "")
        Nazwisko: \(workerObj.surname ?? "")
        Kwota na h: \(UserDefaults.standard.string(forKey: UD_EXPENSE_CURRENCY) ?? "")\(workerObj.amount)
        
        Data: \(getDateFormatter(date: workerObj.occuredOn, format: "EEEE, dd MMM hh:mm a"))
        Notatka: \(workerObj.note ?? "")
        
        \(SHARED_FROM_EXPENSO)
        """
        let av = UIActivityViewController(activityItems: [shareStr], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
}
/*
struct WorkerDetailedViewModel_Previews: PreviewProvider {
    static var previews: some View {
        WorkerDetailedViewModel()
    }
}
*/
