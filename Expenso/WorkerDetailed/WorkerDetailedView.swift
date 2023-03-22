//
//  WorkerDetailedView.swift
//  Expenso
//
//  Created by Marek Wala on 25/04/2021.
//

import SwiftUI

struct WorkerDetailedView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // CoreData
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject private var viewModel: WorkerDetailedViewModel
    @AppStorage(UD_EXPENSE_CURRENCY) var CURRENCY: String = ""
    
    @State private var confirmDelete = false
    
    init(workerObj: WorkerCD) {
        viewModel = WorkerDetailedViewModel(workerObj: workerObj)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.primary_color.edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    ToolbarModelView(title: "SZCZEGÓŁOWY OPIS", button1Icon: IMAGE_DELETE_ICON, button2Icon: IMAGE_SHARE_ICON) { self.presentationMode.wrappedValue.dismiss() }
                        button1Method: { self.confirmDelete = true }
                        button2Method: { viewModel.shareNote() }
                    
                    ScrollView(showsIndicators: false) {
                        
                        VStack(spacing: 24) {
                            ExpenseDetailedListView(title: "Imie", description: viewModel.workerObj.name ?? "")
                            ExpenseDetailedListView(title: "Nazwisko", description: viewModel.workerObj.surname ?? "")
                            ExpenseDetailedListView(title: "Kwota na h", description: "\(CURRENCY)\(viewModel.workerObj.amount)")
                            
                            ExpenseDetailedListView(title: "Kiedy", description: getDateFormatter(date: viewModel.workerObj.occuredOn, format: "EEEE, dd MMM hh:mm a"))
                            if let note = viewModel.workerObj.note, note != "" {
                                ExpenseDetailedListView(title: "Notatka", description: note)
                            }
                            if let workAgreement = viewModel.workerObj.workAgreement, workAgreement != false {
                                ExpenseDetailedListView(title: "Czy umowa o prace?", description: "Czy umowa o prace?")
                            }
                            if let data = viewModel.workerObj.imageAttached {
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
                                    Alert(title: Text(APP_NAME), message: Text("Jesteś pewny, że chcesz usunąć pracownika?"),
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
                        NavigationLink(destination: AddWorkerView(viewModel: AddWorkerViewModel(workerObj: viewModel.workerObj)), label: {
                            Image("pencil_icon").resizable().frame(width: 28.0, height: 28.0)
                            Text("Edit").modifier(InterFont(.semiBold, size: 18)).foregroundColor(.white)
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

struct WorkerDetailedListView: View {
    
    var title: String
    var description: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack { TextView(text: title, type: .caption).foregroundColor(Color.init(hex: "828282")); Spacer() }
            HStack { TextView(text: description, type: .body_1).foregroundColor(Color.text_primary_color); Spacer() }
        }
    }
}
/*
struct WorkerDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        WorkerDetailedView()
    }
}
*/
