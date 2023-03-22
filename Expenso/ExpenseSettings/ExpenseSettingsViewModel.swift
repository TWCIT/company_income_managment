//
//  ExpenseSettingsViewModel.swift
//  Expenso
//
//  Created by Sameer Nawaz on 31/01/21.
//

import UIKit
import CoreData
import LocalAuthentication

class ExpenseSettingsViewModel: ObservableObject {
    
    var csvModelArr = [ExpenseCSVModel]()
    
    @Published var currency = UserDefaults.standard.string(forKey: UD_EXPENSE_CURRENCY) ?? ""
    @Published var enableBiometric = UserDefaults.standard.bool(forKey: UD_USE_BIOMETRIC) {
        didSet {
            if enableBiometric { authBiometric() }
            else { UserDefaults.standard.setValue(false, forKey: UD_USE_BIOMETRIC) }
        }
    }
    
    @Published var alertMsg = String()
    @Published var showAlert = false
    
    init() {}
    
    func authBiometric() {
        let scanner = LAContext()
        var error: NSError?
        if scanner.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            scanner.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "To Unlock \(APP_NAME)") { (status, err) in
                if let err = err {
                    DispatchQueue.main.async {
                        self.enableBiometric = false
                        self.alertMsg = err.localizedDescription
                        self.showAlert = true
                    }
                } else { UserDefaults.standard.setValue(true, forKey: UD_USE_BIOMETRIC) }
            }
        } else if scanner.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            scanner.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "To Unlock \(APP_NAME)") { (status, err) in
                if let err = err {
                    DispatchQueue.main.async {
                        self.enableBiometric = false
                        self.alertMsg = err.localizedDescription
                        self.showAlert = true
                    }
                } else { UserDefaults.standard.setValue(true, forKey: UD_USE_BIOMETRIC) }
            }
        }
    }
    
    func getBiometricType() -> String {
        if #available(iOS 11.0, *) {
            let context = LAContext()
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                switch context.biometryType {
                    case .faceID: return "Face ID"
                    case .touchID: return "Touch ID"
                    case .none: return "App Lock"
                    @unknown default: return "App Lock"
                }
            }
        }
        return "App Lock"
    }
    
    func saveCurrency(currency: String) {
        self.currency = currency
        UserDefaults.standard.set(currency, forKey: UD_EXPENSE_CURRENCY)
    }
    
    func exportTransactions(moc: NSManagedObjectContext,worker: WorkerCD) {
        clearTmpDirectory()

        /*let sortDescriptor = NSSortDescriptor(key: "occuredOn", ascending: false)
        var fetchRequest: FetchRequest<ExpenseCD>
        
        var endDate = Date().getThisMonthEnd()! as NSDate
        var startDate = Date().getThisMonthStart()! as NSDate
        let predicate = NSPredicate(format: "occuredOn >= %@ AND occuredOn <= %@ AND name == %@", startDate, endDate, "Adam Kubów")
        let request = FetchRequest<ExpenseCD>(entity: ExpenseCD.entity(), sortDescriptors: [sortDescriptor], predicate: predicate)
 */
        
        //fetchRequest = FetchRequest<ExpenseCD>(entity: ExpenseCD.entity(), sortDescriptors: [sortDescriptor],predicate: predicate)
        /*
        func getTotalBalance() -> String {
            var value = Double(0)
            for i in results {
                if i.type == TRANS_TYPE_INCOME { value += i.amount }
                else if i.type == TRANS_TYPE_EXPENSE { value -= i.amount }
            }
            return "\(String(format: "%.2f", value))"
        }*/
        let request: NSFetchRequest<ExpenseCD> = ExpenseCD.fetchRequest() as! NSFetchRequest<ExpenseCD>
        let endDate = Date().getThisMonthEnd()! as NSDate
        let startDate = Date().getThisMonthStart()! as NSDate
        let workerT = worker
        let predicate = NSPredicate(format: "occuredOn >= %@ AND occuredOn <= %@ AND expanseWorker == %@", startDate, endDate, workerT)
        let sortDescriptor = NSSortDescriptor(key: "occuredOn", ascending: false)
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        var value = Double(0)
        var results: [ExpenseCD]
        do {
            results = try moc.fetch(request)
            if results.count <= 0 { alertMsg = "Brak danych do wyeksportowania"; showAlert = true }
            
            else {
                for i in results {
                    let csvModel = ExpenseCSVModel()
                    if i.type == TRANS_TYPE_INCOME { value += i.amount }
                    else if i.type == TRANS_TYPE_EXPENSE { value -= i.amount }
                    csvModel.title = i.title ?? ""
                    csvModel.amount = "\(i.type == TRANS_TYPE_INCOME ? "" : "-")\(i.amount)\(currency)"
                    
                    csvModel.transactionType = "\(i.type == TRANS_TYPE_INCOME ? "Przychód(+)" : "Koszta(-)")"
                    csvModel.tag = getTransTagTitle(transTag: i.tag ?? "")
                    csvModel.occuredOn = "\(getDateFormatter(date: i.occuredOn, format: "yyyy-MM-dd"))"
                    csvModel.note = i.note ?? ""
                    csvModel.sum = "\(String(format: "%.2f", value))\(currency)"
                    csvModelArr.append(csvModel)
                }
                
                
                self.generateCSV(worker: worker)
            }
        } catch { alertMsg = "\(error)"; showAlert = true }
      //  clearTmpDirectory()
    }
    func exportTransactionsLast(moc: NSManagedObjectContext,worker: WorkerCD) {
        clearTmpDirectory()

        /*let sortDescriptor = NSSortDescriptor(key: "occuredOn", ascending: false)
        var fetchRequest: FetchRequest<ExpenseCD>
        
        var endDate = Date().getThisMonthEnd()! as NSDate
        var startDate = Date().getThisMonthStart()! as NSDate
        let predicate = NSPredicate(format: "occuredOn >= %@ AND occuredOn <= %@ AND name == %@", startDate, endDate, "Adam Kubów")
        let request = FetchRequest<ExpenseCD>(entity: ExpenseCD.entity(), sortDescriptors: [sortDescriptor], predicate: predicate)
 */
        
        //fetchRequest = FetchRequest<ExpenseCD>(entity: ExpenseCD.entity(), sortDescriptors: [sortDescriptor],predicate: predicate)
        /*
        func getTotalBalance() -> String {
            var value = Double(0)
            for i in results {
                if i.type == TRANS_TYPE_INCOME { value += i.amount }
                else if i.type == TRANS_TYPE_EXPENSE { value -= i.amount }
            }
            return "\(String(format: "%.2f", value))"
        }*/
        let request: NSFetchRequest<ExpenseCD> = ExpenseCD.fetchRequest() as! NSFetchRequest<ExpenseCD>
        let endDate = Date().getLastMonthEnd()! as NSDate
        let startDate = Date().getLastMonthStart()! as NSDate
        let workerT = worker
        let predicate = NSPredicate(format: "occuredOn >= %@ AND occuredOn <= %@ AND expanseWorker == %@", startDate, endDate, workerT)
        let sortDescriptor = NSSortDescriptor(key: "occuredOn", ascending: false)
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        var value = Double(0)
        var results: [ExpenseCD]
        do {
            results = try moc.fetch(request)
            if results.count <= 0 { alertMsg = "Brak danych do wyeksportowania"; showAlert = true }
            
            else {
                for i in results {
                    let csvModel = ExpenseCSVModel()
                    if i.type == TRANS_TYPE_INCOME { value += i.amount }
                    else if i.type == TRANS_TYPE_EXPENSE { value -= i.amount }
                    csvModel.title = i.title ?? ""
                    csvModel.amount = "\(i.type == TRANS_TYPE_INCOME ? "" : "-")\(i.amount)\(currency)"
                    
                    csvModel.transactionType = "\(i.type == TRANS_TYPE_INCOME ? "Przychód(+)" : "Koszta(-)")"
                    csvModel.tag = getTransTagTitle(transTag: i.tag ?? "")
                    csvModel.occuredOn = "\(getDateFormatter(date: i.occuredOn, format: "yyyy-MM-dd"))"
                    csvModel.note = i.note ?? ""
                    csvModel.sum = "\(String(format: "%.2f", value))\(currency)"
                    csvModelArr.append(csvModel)
                }
                
                
                self.generateCSV(worker: worker)
            }
        } catch { alertMsg = "\(error)"; showAlert = true }
  //      clearTmpDirectory()
    }
    func exportTransactionsAll(moc: NSManagedObjectContext,worker: WorkerCD) {
        /*let sortDescriptor = NSSortDescriptor(key: "occuredOn", ascending: false)
        var fetchRequest: FetchRequest<ExpenseCD>
        
        var endDate = Date().getThisMonthEnd()! as NSDate
        var startDate = Date().getThisMonthStart()! as NSDate
        let predicate = NSPredicate(format: "occuredOn >= %@ AND occuredOn <= %@ AND name == %@", startDate, endDate, "Adam Kubów")
        let request = FetchRequest<ExpenseCD>(entity: ExpenseCD.entity(), sortDescriptors: [sortDescriptor], predicate: predicate)
 */
        
        //fetchRequest = FetchRequest<ExpenseCD>(entity: ExpenseCD.entity(), sortDescriptors: [sortDescriptor],predicate: predicate)
        /*
        func getTotalBalance() -> String {
            var value = Double(0)
            for i in results {
                if i.type == TRANS_TYPE_INCOME { value += i.amount }
                else if i.type == TRANS_TYPE_EXPENSE { value -= i.amount }
            }
            return "\(String(format: "%.2f", value))"
        }*/
        clearTmpDirectory()

        let request: NSFetchRequest<ExpenseCD> = ExpenseCD.fetchRequest() as! NSFetchRequest<ExpenseCD>

        let workerT = worker
        let predicate = NSPredicate(format: "expanseWorker == %@", workerT)
        let sortDescriptor = NSSortDescriptor(key: "occuredOn", ascending: false)
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptor]
        var value = Double(0)
        var results: [ExpenseCD]
        do {
            results = try moc.fetch(request)
            if results.count <= 0 { alertMsg = "Brak danych do wyeksportowania"; showAlert = true }
            
            else {
                for i in results {
                    let csvModel = ExpenseCSVModel()
                    if i.type == TRANS_TYPE_INCOME { value += i.amount }
                    else if i.type == TRANS_TYPE_EXPENSE { value -= i.amount }
                    csvModel.title = i.title ?? ""
                    csvModel.amount = "\(i.type == TRANS_TYPE_INCOME ? "" : "-")\(i.amount)\(currency)"
                    
                    csvModel.transactionType = "\(i.type == TRANS_TYPE_INCOME ? "Przychód(+)" : "Koszta(-)")"
                    csvModel.tag = getTransTagTitle(transTag: i.tag ?? "")
                    csvModel.occuredOn = "\(getDateFormatter(date: i.occuredOn, format: "yyyy-MM-dd"))"
                    csvModel.note = i.note ?? ""
                    csvModel.sum = "\(String(format: "%.2f", value))\(currency)"
                    csvModelArr.append(csvModel)
                }
                
                
                self.generateCSV(worker: worker)
                            }
        } catch { alertMsg = "\(error)"; showAlert = true }
   //     clearTmpDirectory()

        
    }
    func generateCSV(worker: WorkerCD) {
        clearTmpDirectory()

        let fileName = "IVG_zarobki_miesieczne_" + worker.name! + "_" + worker.surname! + ".csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Tytul,Kwota,Typ,Rodzaj,Dodane dnia,Notatka,Suma\n"
        let size = csvModelArr.count
        var i = 0
        for csvModel in csvModelArr {
            i += 1
            let row = "\"\(csvModel.title)\",\"\(csvModel.amount)\",\"\(csvModel.transactionType)\",\"\(csvModel.tag)\",\"\(csvModel.occuredOn)\",\"\(csvModel.note)\",\"\("")\"\n"
            csvText.append(row)
            if i == size{
                let row2 = "\"\("")\",\"\("")\",\"\("")\",\"\("")\",\"\("")\",\"\("")\",\"\(csvModel.sum)\"\n"
                csvText.append(row2)
            }
            
            
            
        }
        
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            let av = UIActivityViewController(activityItems: [path!], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
            
        } catch { alertMsg = "\(error)"; showAlert = true }
       // clearTmpDirectory()
        print(path ?? "not found")
    }
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach { file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try FileManager.default.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
