//
//  AddWorkerViewModel.swift
//  Expenso
//
//  Created by Marek Wala on 25/04/2021.
//

import SwiftUI
import CoreData
/*
 @NSManaged public var updatedAt: Date?
 @NSManaged public var tag: String?
 @NSManaged public var name: String?
 @NSManaged public var surname: String?
 @NSManaged public var occuredOn: Date?
 @NSManaged public var note: String?
 @NSManaged public var imageAttached: Data?
 @NSManaged public var createdAt: Date?
 @NSManaged public var amount: Double
 @NSManaged public var workAgreement: Bool
 @NSManaged public var relationship: NSSet?

 */
class AddWorkerViewModel: ObservableObject  {
    
    var workerObj: WorkerCD?
    /*
    @Published var title = ""
    @Published var amount = ""
    @Published var occuredOn = Date()
    @Published var note = ""
    @Published var typeTitle = "Income"
    @Published var tagTitle = getTransTagTitle(transTag: TRANS_TAG_TRANSPORT)
    @Published var showTypeDrop = false
    @Published var showTagDrop = false
    
    @Published var selectedType = TRANS_TYPE_INCOME
    @Published var selectedTag = TRANS_TAG_TRANSPORT
    
    @Published var imageUpdated = false // When transaction edit, check if attachment is updated?
    @Published var imageAttached: UIImage? = nil
    
    @Published var alertMsg = String()
    @Published var showAlert = false
    @Published var closePresenter = false
    */
    
//    @Published var updatedAt: Date?
//    @Published var tag: String?
    @Published var name = ""
    @Published var surname = ""
    @Published var occuredOn = Date()
    @Published var note = ""
    @Published var imageAttached: UIImage? = nil
    @Published var createdAt: Date?
    @Published var amount = ""
    @Published var monthly = ""
    @Published var workAgreement = false
    
    
    @Published var imageUpdated = false // When transaction edit, check if attachment is updated?
    @Published var alertMsg = String()
 //   @Published var relationship: NSSet?
    @Published var showAlert = false
    @Published var closePresenter = false
    
    init(workerObj: WorkerCD? = nil) {
        
        self.workerObj = workerObj
        self.name = workerObj?.name ?? ""
        self.surname = workerObj?.surname ?? ""
        self.workAgreement = workerObj?.workAgreement ?? false
        if let workerObj = workerObj {
            self.amount = String(workerObj.amount)
            
        } else {
            self.amount = ""
            
        }
        if let workerObj = workerObj {
            self.monthly = String(workerObj.monthly)
            
        } else {
            self.monthly = ""
            
        }
        self.occuredOn = workerObj?.occuredOn ?? Date()
        self.note = workerObj?.note ?? ""
        if let data = workerObj?.imageAttached {
            self.imageAttached = UIImage(data: data)
        }
        
        AttachmentHandler.shared.imagePickedBlock = { [weak self] image in
            self?.imageUpdated = true
            self?.imageAttached = image
        }
    }
    
    func getButtText() -> String {
        return "\(workerObj == nil ? "Dodaj" : "Edytuj") pracownika"
    }
    
    func attachImage() { AttachmentHandler.shared.showAttachmentActionSheet() }
    
    func removeImage() { imageAttached = nil }
    
    func saveWorker(managedObjectContext: NSManagedObjectContext) {
        
        let worker: WorkerCD
        let nameStr = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let surnameStr = surname.trimmingCharacters(in: .whitespacesAndNewlines)
        let amountStr = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        let monthlyStr = monthly.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if nameStr.isEmpty || nameStr == "" {
            alertMsg = "Wpisz tytuł"; showAlert = true
            return
        }
        if surnameStr.isEmpty || surnameStr == "" {
            alertMsg = "Wpisz tytuł"; showAlert = true
            return
        }
        if amountStr.isEmpty || amountStr == "" {
            alertMsg = "Wpisz kwote na h"; showAlert = true
            return
        }
        guard let amount = Double(amountStr) else {
            alertMsg = "Wpisz liczbę, nie litere czy znak specjalny"; showAlert = true
            return
        }
        guard let monthly = Double(monthlyStr) else {
            alertMsg = "Wpisz liczbę, nie litere czy znak specjalny"; showAlert = true
            return
        }
        
        if workerObj != nil {
            
            worker = workerObj!
            
            if let image = imageAttached {
                if imageUpdated {
                    if let _ = worker.imageAttached {
                        // Delete Previous Image from CoreData
                    }
                    worker.imageAttached = image.jpegData(compressionQuality: 1.0)
                }
            } else {
                if let _ = worker.imageAttached {
                    // Delete Previous Image from CoreData
                }
                worker.imageAttached = nil
            }
            
        } else {
            worker = WorkerCD(context: managedObjectContext)
            worker.createdAt = Date()
            if let image = imageAttached {
                worker.imageAttached = image.jpegData(compressionQuality: 1.0)
            }
        }
        worker.workAgreement = workAgreement
        worker.updatedAt = Date()
        worker.name = nameStr
        worker.surname = surnameStr
        worker.occuredOn = occuredOn
        worker.note = note
        worker.amount = amount
        worker.monthly = monthly
        do {
            try managedObjectContext.save()
            closePresenter = true
        } catch { alertMsg = "\(error)"; showAlert = true }
    }
    
    func deleteWorker(managedObjectContext: NSManagedObjectContext) {
        guard let workerObj = workerObj else { return }
        managedObjectContext.delete(workerObj)
        do {
            try managedObjectContext.save(); closePresenter = true
        } catch { alertMsg = "\(error)"; showAlert = true }
    }
}

/*
struct AddWorkerViewModel_Previews: PreviewProvider {
    static var previews: some View {
        AddWorkerViewModel()
    }
}
*/
