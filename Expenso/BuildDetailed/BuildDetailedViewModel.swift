//
//  WorkerDetailedViewModel.swift
//  Expenso
//
//  Created by Marek Wala on 26/04/2021.
//

import SwiftUI
class BuildDetailedViewModel: ObservableObject {
    
    @Published var buildObj: BuildCD
    
    @Published var alertMsg = String()
    @Published var showAlert = false
    @Published var closePresenter = false
    
    init(buildObj: BuildCD) {
        self.buildObj = buildObj
    }
    
    func deleteNote(managedObjectContext: NSManagedObjectContext) {
        managedObjectContext.delete(buildObj)
        do {
            try managedObjectContext.save(); closePresenter = true
        } catch { alertMsg = "\(error)"; showAlert = true }
    }
    
    func shareNote() {
        let shareStr = """
        Tytuł: \(buildObj.title ?? "")
        Tag: \(buildObj.tag ?? "")
        Kwota: \(UserDefaults.standard.string(forKey: UD_EXPENSE_CURRENCY) ?? "")\(buildObj.amount)
        
        Data: \(getDateFormatter(date: buildObj.occuredOn, format: "EEEE, dd MMM hh:mm a"))
        Notatka: \(buildObj.note ?? "")
        
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
