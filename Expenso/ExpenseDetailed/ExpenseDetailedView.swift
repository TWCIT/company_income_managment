//
//  ExpenseDetailedView.swift
//  Expenso
//
//  Created by Sameer Nawaz on 31/01/21.
//

import SwiftUI

struct ExpenseDetailedView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // CoreData
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject private var viewModel: ExpenseDetailedViewModel
    @AppStorage(UD_EXPENSE_CURRENCY) var CURRENCY: String = ""
    
    @State private var confirmDelete = false
    
    init(expenseObj: ExpenseCD) {
        viewModel = ExpenseDetailedViewModel(expenseObj: expenseObj)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primary_color.edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    ToolbarModelView(title: "Szczegółowy opis", button1Icon: IMAGE_DELETE_ICON, button2Icon: IMAGE_SHARE_ICON) { self.presentationMode.wrappedValue.dismiss() }
                        button1Method: { self.confirmDelete = true }
                        button2Method: { viewModel.shareNote() }
                    
                    ScrollView(showsIndicators: false) {
                        
                        VStack(spacing: 24) {
                            ExpenseDetailedListView(title: "Tytuł", description: viewModel.expenseObj.title ?? "")
                            ExpenseDetailedListView(title: "Kwota", description: "\(CURRENCY)\(viewModel.expenseObj.amount)")
                            ExpenseDetailedListView(title: "Typ transakcji", description: viewModel.expenseObj.type == TRANS_TYPE_INCOME ? "Przychód" : "Wydatek" )
                            ExpenseDetailedListView(title: "Tag", description: getTransTagTitle(transTag: viewModel.expenseObj.tag ?? ""))
                            ExpenseDetailedListView(title: "Z kiedy", description: getDateFormatter(date: viewModel.expenseObj.occuredOn, format: "EEEE, dd MMM hh:mm a"))
                            if let note = viewModel.expenseObj.note, note != "" {
                                ExpenseDetailedListView(title: "Notakta", description: note)
                            }
                            if let name = viewModel.expenseObj.expanseWorker?.name, name != "" {
                                NavigationLink(destination: WorkerDetailedView(workerObj: viewModel.expenseObj.expanseWorker!), label: {ExpenseDetailedListView(title: "Imie pracownika", description: name).foregroundColor(Color.red)})
                            }
                            if let surname = viewModel.expenseObj.expanseWorker?.surname, surname != "" {
                                NavigationLink(destination: WorkerDetailedView(workerObj: viewModel.expenseObj.expanseWorker!), label: {ExpenseDetailedListView(title: "Nazwisko pracownika", description: surname).foregroundColor(Color.red)})
                            }
                            if let data = viewModel.expenseObj.imageAttached {
                                VStack(spacing: 8) {
                                    HStack { TextView(text: "Załączniki", type: .caption).foregroundColor(Color.init(hex: "828282")); Spacer() }
                                    Image(uiImage: UIImage(data: data)!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 250).frame(maxWidth: .infinity)
                                        .background(Color.secondary_color)
                                        .cornerRadius(4)
                                }
                            }
                        }.padding(16)
                        
                        Spacer().frame(height: 24)
                        Spacer()
                    }
                    .alert(isPresented: $confirmDelete,
                                content: {
                                    Alert(title: Text(APP_NAME), message: Text("Czy na pewno chcesz usunąć tą transakcje?"),
                                        primaryButton: .destructive(Text("Usuń")) {
                                            viewModel.deleteNote(managedObjectContext: managedObjectContext)
                                        }, secondaryButton: Alert.Button.cancel(Text("Anuluj"), action: { confirmDelete = false })
                                    )
                                })
                }.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: AddExpenseView(viewModel: AddExpenseViewModel(expenseObj: viewModel.expenseObj)), label: {
                            Image("pencil_icon").resizable().frame(width: 28.0, height: 28.0)
                            Text("Edytuj").modifier(InterFont(.semiBold, size: 18)).foregroundColor(.white)
                        })
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 20))
                        .background(Color.main_color).cornerRadius(25)
                    }.padding(24)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct ExpenseDetailedListView: View {
    
    var title: String
    var description: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack { TextView(text: title, type: .caption).foregroundColor(Color.init(hex: "828282")); Spacer() }
            HStack { TextView(text: description, type: .body_1).foregroundColor(Color.text_primary_color); Spacer() }
        }
    }
}

//struct ExpenseDetailedView_Previews: PreviewProvider {
//    static var previews: some View {
//        ExpenseDetailedView()
//    }
//}
