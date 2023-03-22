//
//  ExpenseView.swift
//  Expenso
//
//  Created by Sameer Nawaz on 31/01/21.
//

import SwiftUI

struct ExpenseView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // CoreData
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: ExpenseCD.getAllExpenseData(sortBy: ExpenseCDSort.occuredOn, ascending: false)) var expense: FetchedResults<ExpenseCD>
    
    @State private var filter: ExpenseCDFilterTime = .all

    
    @State private var showFilterSheet = false
    @State private var showFilter2Sheet = false
    
    @State private var showOptionsSheet = false
    @State private var displayAbout = false
    @State private var displaySettings = false
    @State private var displaySearch = false
    @State private var displayBuild = false
    @State private var displayWorkerExpanse = false
    @FetchRequest(
        entity: WorkerCD.entity(),
        sortDescriptors: [NSSortDescriptor(key: "occuredOn", ascending: true)]
      ) var items: FetchedResults<WorkerCD>
    var body: some View {
        NavigationView {
            ZStack {
                Color.primary_color.edgesIgnoringSafeArea(.all)
                
                VStack {
                    NavigationLink(destination: NavigationLazyView(ExpenseSettingsView()), isActive: $displaySettings, label: {})
                    NavigationLink(destination: NavigationLazyView(AboutView()), isActive: $displayAbout, label: {})
                    NavigationLink(destination: NavigationLazyView(BuildView()), isActive: $displayBuild, label: {})
                    
                    ToolbarModelView(title: "Centrum kontroli", hasBackButt: false, button1Icon: IMAGE_OPTION_ICON, button2Icon: IMAGE_FILTER_ICON, button3Icon: IMAGE_FILTER_ICON) { self.presentationMode.wrappedValue.dismiss() }
                        
                        button1Method: { self.showOptionsSheet = true }
                        
                        button2Method: { self.showFilterSheet = true }
                        .actionSheet(isPresented: $showFilterSheet) {
                            ActionSheet(title: Text("Wybierz filtr"), buttons: [
                                    .default(Text("Wszystko")) { filter = .all },
                                    .default(Text("Ostatnie 7 dni")) { filter = .week },
                                    .default(Text("Cały miesiąc")) { filter = .month },
                                    .cancel()
                            ])
                            
                        
                    
                        }
                    
                    ExpenseMainView(filter: filter)
                        .actionSheet(isPresented: $showOptionsSheet) {
                            ActionSheet(title: Text("Wybierz menu:"), buttons: [
                                    .default(Text("Pracownicy")) { self.displayAbout = true },
                                    .default(Text("Budowy")) { self.displayBuild = true },
                                    .default(Text("Ustawienia")) { self.displaySettings = true },
                                   // .default(Text("Tylko pracownik")) { self.displayWorkerExpanse = true },
                                    .cancel()
                            ])
                        }
                    Spacer()
                }.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack{
                        NavigationLink(destination: NavigationLazyView(AddExpenseView(viewModel: AddExpenseViewModel())),
                                       label: {
                                        
                                        Image("plus_icon").resizable().frame(width: 32.0, height: 32.0) })
                        .padding().background(Color.main_color).cornerRadius(35)
                        Text("Dodaj wydatek")
                        }
                        VStack{
                        NavigationLink(destination: NavigationLazyView(AddWorkerView(viewModel: AddWorkerViewModel())),
                                       label: {
                                        
                                        Image("plus_icon").resizable().frame(width: 32.0, height: 32.0) })
                        .padding().background(Color.red).cornerRadius(35)
                        Text("Dodaj pracownika")
                        }
                        VStack{
                        NavigationLink(destination: NavigationLazyView(AddBuildView(viewModel: AddBuildViewModel())),
                                       label: {
                                        
                                        Image("plus_icon").resizable().frame(width: 32.0, height: 32.0) })
                        .padding().background(Color.green).cornerRadius(35)
                        Text("Dodaj budowę")
                        }
                    }
                    
                }.padding()
                
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct ExpenseMainView: View {
    
    var filter: ExpenseCDFilterTime
    //var filter2: WorkerCDFilter
    var fetchRequest: FetchRequest<ExpenseCD>
    var expense: FetchedResults<ExpenseCD> { fetchRequest.wrappedValue }
    @AppStorage(UD_EXPENSE_CURRENCY) var CURRENCY: String = ""
    
    init(filter: ExpenseCDFilterTime) {
        let sortDescriptor = NSSortDescriptor(key: "occuredOn", ascending: false)
        self.filter = filter
        if filter == .all {
            fetchRequest = FetchRequest<ExpenseCD>(entity: ExpenseCD.entity(), sortDescriptors: [sortDescriptor])
        } else {
            var startDate: NSDate!
            var endDate: NSDate = NSDate()
            if filter == .week {
                startDate = Date().getLast7Day()! as NSDate
                
            }
            else if filter == .month {
                startDate = Date().getThisMonthStart()! as NSDate
                endDate = Date().getThisMonthEnd()! as NSDate
            }
            else { startDate = Date().getLast6Month()! as NSDate }
            let predicate = NSPredicate(format: "occuredOn >= %@ AND occuredOn <= %@ ", startDate, endDate)
            fetchRequest = FetchRequest<ExpenseCD>(entity: ExpenseCD.entity(), sortDescriptors: [sortDescriptor], predicate: predicate)
        }
    }
    
    private func getTotalBalance() -> String {
        var value = Double(0)
        for i in expense {
            if i.expanseWorker != nil && TRANS_TYPE_INCOME ==  TRANS_TYPE_INCOME{ value -= i.amount }
            else if i.type == TRANS_TYPE_INCOME { value += i.amount }
            else if i.type == TRANS_TYPE_EXPENSE { value -= i.amount }
        }
        return "\(String(format: "%.2f", value))"
    }
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            if fetchRequest.wrappedValue.isEmpty {
                LottieView(animType: .empty_face).frame(width: 300, height: 300)
                VStack {
                    TextView(text: "Brak transakcji na razie!", type: .h6).foregroundColor(Color.text_primary_color)
                    TextView(text: "Dodaj transakcje a tu się pojawi", type: .body_1).foregroundColor(Color.text_secondary_color).padding(.top, 2)
                }.padding(.horizontal)
            } else {
                VStack(spacing: 16) {
                    TextView(text: "Całkowity balans", type: .overline).foregroundColor(Color.init(hex: "828282")).padding(.top, 30)
                    TextView(text: "\(getTotalBalance())\(CURRENCY)", type: .h5).foregroundColor(Color.text_primary_color).padding(.bottom, 30)
                }.frame(maxWidth: .infinity).background(Color.secondary_color).cornerRadius(4)
                
                HStack(spacing: 8) {
                    NavigationLink(destination: NavigationLazyView(ExpenseFilterView(isIncome: true)),
                                   label: { ExpenseModelView(isIncome: true, filter: filter) })
                    NavigationLink(destination: NavigationLazyView(ExpenseFilterView(isIncome: false)),
                                   label: { ExpenseModelView(isIncome: false, filter: filter) })
                }.frame(maxWidth: .infinity)
                
                Spacer().frame(height: 16)
                
                HStack {
                    TextView(text: "Ostatnie transakcje:", type: .subtitle_1).foregroundColor(Color.text_primary_color)
                    Spacer()
                }.padding(4)
                
                ForEach(self.fetchRequest.wrappedValue) { expenseObj in
                    NavigationLink(destination: ExpenseDetailedView(expenseObj: expenseObj), label: { ExpenseTransView(expenseObj: expenseObj) })
                }
            }
            
            Spacer().frame(height: 150)
            
        }.padding(.horizontal, 8).padding(.top, 0)
    }
}

struct ExpenseModelView: View {
    
    var isIncome: Bool
    var type: String
    var fetchRequest: FetchRequest<ExpenseCD>
    var expense: FetchedResults<ExpenseCD> { fetchRequest.wrappedValue }
    @AppStorage(UD_EXPENSE_CURRENCY) var CURRENCY: String = ""
    
    private func getTotalValue() -> String {
        var value = Double(0)
        for i in expense { value += i.amount }
        return "\(String(format: "%.2f", value))"
    }
    
    init(isIncome: Bool, filter: ExpenseCDFilterTime, categTag: String? = nil) {
        self.isIncome = isIncome
        self.type = isIncome ? TRANS_TYPE_INCOME : TRANS_TYPE_EXPENSE
        let sortDescriptor = NSSortDescriptor(key: "occuredOn", ascending: false)
        if filter == .all {
            var predicate: NSPredicate!
            if let tag = categTag {
                predicate = NSPredicate(format: "type == %@ AND tag == %@", type, tag)
            } else { predicate = NSPredicate(format: "type == %@", type) }
            fetchRequest = FetchRequest<ExpenseCD>(entity: ExpenseCD.entity(), sortDescriptors: [sortDescriptor], predicate: predicate)
        } else {
            var startDate: NSDate!
            var endDate: NSDate = NSDate()
            if filter == .week { startDate = Date().getLast7Day()! as NSDate }
            else if filter == .month {
                startDate = Date().getThisMonthStart()! as NSDate
                endDate = Date().getThisMonthEnd()! as NSDate
            }
            else { startDate = Date().getLast6Month()! as NSDate }
            var predicate: NSPredicate!
            if let tag = categTag {
                predicate = NSPredicate(format: "occuredOn >= %@ AND occuredOn <= %@ AND type == %@ AND tag == %@", startDate, endDate, type, tag)
            } else { predicate = NSPredicate(format: "occuredOn >= %@ AND occuredOn <= %@ AND type == %@", startDate, endDate, type) }
            fetchRequest = FetchRequest<ExpenseCD>(entity: ExpenseCD.entity(), sortDescriptors: [sortDescriptor], predicate: predicate)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Image(isIncome ? "income_icon" : "expense_icon").resizable().frame(width: 40.0, height: 40.0).padding(12)
            }
            HStack{
                TextView(text: isIncome ? "PRZYCHÓD" : "WYDATEK", type: .overline).foregroundColor(Color.init(hex: "828282"))
                Spacer()
            }.padding(.horizontal, 12)
            HStack {
                TextView(text: "\(getTotalValue())\(CURRENCY)", type: .h5, lineLimit: 1).foregroundColor(Color.text_primary_color)
                Spacer()
            }.padding(.horizontal, 12)
        }.padding(.bottom, 12).background(Color.secondary_color).cornerRadius(4)
    }
}

struct ExpenseTransView: View {
    
    @ObservedObject var expenseObj: ExpenseCD
    @AppStorage(UD_EXPENSE_CURRENCY) var CURRENCY: String = ""
    
    var body: some View {
        HStack {
            
            NavigationLink(destination: NavigationLazyView(ExpenseFilterView(categTag: expenseObj.tag)), label: {
                Image(getTransTagIcon(transTag: expenseObj.tag ?? ""))
                    .resizable().frame(width: 24, height: 24).padding(16)
                    .background(Color.primary_color).cornerRadius(4)
            })
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    if expenseObj.paidIs {
                    TextView(text: expenseObj.title ?? "", type: .subtitle_1, lineLimit: 1).foregroundColor(Color.text_primary_color)
                    }
                    else{
                    TextView(text: expenseObj.title ?? "", type: .subtitle_1, lineLimit: 1).foregroundColor(Color.yellow)
                    }
                    Text(expenseObj.expanseWorker?.name ?? "").foregroundColor(Color.red)
                    Text(expenseObj.expanseBuild?.title ?? "").foregroundColor(Color.green)
                    Text(" ")
                    Text(expenseObj.expanseWorker?.surname ?? "").foregroundColor(Color.red)
                    
                    Spacer()
                    TextView(text: "\((expenseObj.type == TRANS_TYPE_INCOME && expenseObj.expanseWorker == nil) ? "+" : "-")\(expenseObj.amount)\(CURRENCY)", type: .subtitle_1)
                        .foregroundColor((expenseObj.type == TRANS_TYPE_INCOME && expenseObj.expanseWorker == nil) ? Color.main_green : Color.main_red)
                        .foregroundColor((expenseObj.type == TRANS_TYPE_INCOME && expenseObj.expanseWorker == nil) ? Color.text_primary_color : Color.main_green)
                }
                HStack {
                    TextView(text: getTransTagTitle(transTag: expenseObj.tag ?? ""), type: .body_2).foregroundColor(Color.text_primary_color)
                    Spacer()
                    TextView(text: getDateFormatter(date: expenseObj.occuredOn, format: "dd MMM yyyy"), type: .body_2).foregroundColor(Color.text_primary_color) .environment(\.locale, Locale.init(identifier: "pl"))
                        
                }
            }.padding(.leading, 4)
            
            Spacer()
            
        }.padding(8).background(Color.secondary_color).cornerRadius(4)
    }
}
/*
struct ExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseView()
    }
}
*/
