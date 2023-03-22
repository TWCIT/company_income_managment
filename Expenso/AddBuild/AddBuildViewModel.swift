//
//  AddBuildViewModel.swift
//  Expenso
//
//  Created by Marek Wala on 26/04/2021.
//

import SwiftUI
import CoreData

class AddBuildViewModel: ObservableObject {
    var buildObj: BuildCD?
    /*
     @NSManaged public var title: String?
     @NSManaged public var amount: Double
     @NSManaged public var createdAt: Date?
     @NSManaged public var imageAttached: Data?
     @NSManaged public var note: String?
     @NSManaged public var occuredOn: Date?
     @NSManaged public var tag: String?
     @NSManaged public var updatedAt: Date?
     @NSManaged public var relationship: NSSet?
     */
    @Published var title = ""
    @Published var occuredOn = Date()
    @Published var note = ""
    @Published var tag = ""
    @Published var imageAttached: UIImage? = nil
    @Published var createdAt: Date?
    @Published var amount = ""
    
    
    @Published var imageUpdated = false // When transaction edit, check if attachment is updated?
    @Published var alertMsg = String()
 //   @Published var relationship: NSSet?
    @Published var showAlert = false
    @Published var closePresenter = false
    
    init(buildObj: BuildCD? = nil) {
        
        self.buildObj = buildObj
        self.title = buildObj?.title ?? ""
        self.tag = buildObj?.tag ?? ""
                if let buildObj = buildObj {
            self.amount = String(buildObj.amount)
            
        } else {
            self.amount = ""
            
        }
        self.occuredOn = buildObj?.occuredOn ?? Date()
        self.note = buildObj?.note ?? ""
        if let data = buildObj?.imageAttached {
            self.imageAttached = UIImage(data: data)
        }
        
        AttachmentHandler.shared.imagePickedBlock = { [weak self] image in
            self?.imageUpdated = true
            self?.imageAttached = image
        }
    }
    
    func getButtText() -> String {
        return "\(buildObj == nil ? "DODAJ" : "EDYTUJ") PRACOWNIKA"
    }
    
    func attachImage() { AttachmentHandler.shared.showAttachmentActionSheet() }
    
    func removeImage() { imageAttached = nil }
    
    func saveBuild(managedObjectContext: NSManagedObjectContext) {
        
        let build: BuildCD
        let nameStr = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let surnameStr = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        let amountStr = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if nameStr.isEmpty || nameStr == "" {
            alertMsg = "Wpisz tytuł"; showAlert = true
            return
        }
        if surnameStr.isEmpty || surnameStr == "" {
            alertMsg = "Wpisz tytuł"; showAlert = true
            return
        }
        if amountStr.isEmpty || amountStr == "" {
            alertMsg = "Wpisz kwote"; showAlert = true
            return
        }
        guard let amount = Double(amountStr) else {
            alertMsg = "Wpisz cyfre, bez znaków jak litery czy znaki specjalne"; showAlert = true
            return
        }
        
        if buildObj != nil {
            
            build = buildObj!
            
            if let image = imageAttached {
                if imageUpdated {
                    if let _ = build.imageAttached {
                        // Delete Previous Image from CoreData
                    }
                    build.imageAttached = image.jpegData(compressionQuality: 1.0)
                }
            } else {
                if let _ = build.imageAttached {
                    // Delete Previous Image from CoreData
                }
                build.imageAttached = nil
            }
            
        } else {
            build = BuildCD(context: managedObjectContext)
            build.createdAt = Date()
            if let image = imageAttached {
                build.imageAttached = image.jpegData(compressionQuality: 1.0)
            }
        }
        
        build.updatedAt = Date()
        build.title = nameStr
        build.tag = surnameStr
        build.occuredOn = occuredOn
        build.note = note
        build.amount = amount
        do {
            try managedObjectContext.save()
            closePresenter = true
        } catch { alertMsg = "\(error)"; showAlert = true }
    }
    
    func deleteBuild(managedObjectContext: NSManagedObjectContext) {
        guard let buildObj = buildObj else { return }
        managedObjectContext.delete(buildObj)
        do {
            try managedObjectContext.save(); closePresenter = true
        } catch { alertMsg = "\(error)"; showAlert = true }
    }
}
/*
struct AddBuildViewModel_Previews: PreviewProvider {
    static var previews: some View {
        AddBuildViewModel()
    }
}
*/
