//
//  AddBuildExpenseView.swift
//  Expenso
//
//  Created by Marek Wala on 07/05/2021.
//


import SwiftUI
import CoreData
struct AddBuildExpenseView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // CoreData
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var confirmDelete = false
    @State var showAttachSheet = false
    @FetchRequest(
        entity: WorkerCD.entity(),
        sortDescriptors: [NSSortDescriptor(key: "occuredOn", ascending: true)]
      ) var items: FetchedResults<WorkerCD>
    @FetchRequest(
        entity: BuildCD.entity(),
        sortDescriptors: [NSSortDescriptor(key: "occuredOn", ascending: true)]
      ) var items2: FetchedResults<BuildCD>
    @StateObject var viewModel: AddBuildExpenseViewModel
    
    let typeOptions = [
        DropdownOption(key: TRANS_TYPE_INCOME, val: "Przychód"),
        DropdownOption(key: TRANS_TYPE_EXPENSE, val: "Koszta")
    ]
    
    let tagOptions = [
        DropdownOption(key: TRANS_TAG_TRANSPORT, val: "Transport"),
        DropdownOption(key: TRANS_TAG_FOOD, val: "Jedzenie"),
        DropdownOption(key: TRANS_TAG_HOUSING, val: "Nocleg"),
        DropdownOption(key: TRANS_TAG_INSURANCE, val: "Ubezpieczenie"),
        DropdownOption(key: TRANS_TAG_MEDICAL, val: "Medyczne"),
        DropdownOption(key: TRANS_TAG_SAVINGS, val: "Oszczednosci"),
        DropdownOption(key: TRANS_TAG_PERSONAL, val: "Pracownicy"),
        DropdownOption(key: TRANS_TAG_ENTERTAINMENT, val: "Rozrywka"),
        DropdownOption(key: TRANS_TAG_OTHERS, val: "Inne"),
        DropdownOption(key: TRANS_TAG_UTILITIES, val: "Materialy")
    ]
    func toggle(){viewModel.paidIs = !viewModel.paidIs}
    var body: some View {
        
        VStack{
        NavigationView {
            ZStack {
                Color.primary_color.edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    Group {
                        if viewModel.expenseObj == nil {
                            ToolbarModelView(title: "Dodaj transakcje") { self.presentationMode.wrappedValue.dismiss() }
                        } else {
                            ToolbarModelView(title: "Edytuj transakcje", button1Icon: IMAGE_DELETE_ICON) { self.presentationMode.wrappedValue.dismiss() }
                                button1Method: { self.confirmDelete = true }
                        }
                    }.alert(isPresented: $confirmDelete,
                            content: {
                                Alert(title: Text(APP_NAME), message: Text("Czy jesteś pewny, że chcesz usunąć tą transakcję?"),
                                    primaryButton: .destructive(Text("Usuń")) {
                                        viewModel.deleteTransaction(managedObjectContext: self.managedObjectContext)
                                    }, secondaryButton: Alert.Button.cancel(Text("Anuluj"), action: { confirmDelete = false })
                                )
                            })
                    
                    ScrollView(showsIndicators: false) {
                        
                        VStack(spacing: 12) {
                            
                            TextField("Tytuł", text: $viewModel.title)
                                .modifier(InterFont(.regular, size: 16))
                                .accentColor(Color.text_primary_color)
                                .frame(height: 50).padding(.leading, 16)
                                .background(Color.secondary_color)
                                .cornerRadius(4)
                            
                          
                            
                            
                        
                            TextField("Kwota za całość", text: $viewModel.amount)
                                .modifier(InterFont(.regular, size: 16))
                                .accentColor(Color.text_primary_color)
                                .frame(height: 50).padding(.leading, 16)
                                .background(Color.secondary_color)
                                .cornerRadius(4).keyboardType(.decimalPad)
                            
                            
                            
                            HStack {
                                DatePicker("PickerView", selection: $viewModel.occuredOn,
                                           displayedComponents: [.date]).labelsHidden().padding(.leading, 16).datePickerStyle(GraphicalDatePickerStyle())
                                    .environment(\.locale, Locale.init(identifier: "pl"))
                                Spacer()
                                VStack{
                                    Spacer()
                                    Text("Ile h pracy?(podstawowa wartość 1)")
                                    TextField("Godziny pracy:", text: $viewModel.amount2).accentColor(Color.text_primary_color)
                                        .background(Color.black).cornerRadius(4)
                                    Text("Ile dni wolnych?(podstawowa wartość 0)")
                                    TextField("Dni wolne:", text: $viewModel.amount3).accentColor(Color.text_primary_color)
                                        .background(Color.black).cornerRadius(4)
                                      
                                    Spacer()
                                Button(action: toggle){
                                            HStack{
                                                Image(systemName: viewModel.paidIs ? "checkmark.square": "square")
                                                Text("Czy zostało uregulowane?")
                                            }

                                        }
                                    Spacer()
                                }
                                Spacer()
                                DatePicker("PickerView", selection: $viewModel.occuredTo,
                                           displayedComponents: [.date ]).labelsHidden().padding(.leading, 16).datePickerStyle(GraphicalDatePickerStyle())
                                    .environment(\.locale, Locale.init(identifier: "pl"))
                                
                            }
                            //.frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .accentColor(Color.text_primary_color)
                            .background(Color.secondary_color).cornerRadius(4)
                            
                            
                            TextField("Notatka", text: $viewModel.note)
                                .modifier(InterFont(.regular, size: 16))
                                .accentColor(Color.text_primary_color)
                                .frame(height: 50).padding(.leading, 16)
                                .background(Color.secondary_color)
                                .cornerRadius(4)
                            DropdownButton(shouldShowDropdown: $viewModel.showTypeDrop, displayText: $viewModel.typeTitle,
                                           options: typeOptions, mainColor: Color.text_primary_color,
                                           backgroundColor: Color.secondary_color, cornerRadius: 4, buttonHeight: 50) { key in
                                let selectedObj = typeOptions.filter({ $0.key == key }).first
                                if let object = selectedObj {
                                    viewModel.typeTitle = object.val
                                    viewModel.selectedType = key
                                }
                                viewModel.showTypeDrop = false
                            }
                            
                            DropdownButton(shouldShowDropdown: $viewModel.showTagDrop, displayText: $viewModel.tagTitle,
                                           options: tagOptions, mainColor: Color.text_primary_color,
                                           backgroundColor: Color.secondary_color, cornerRadius: 4, buttonHeight: 50) { key in
                                let selectedObj = tagOptions.filter({ $0.key == key }).first
                                if let object = selectedObj {
                                    viewModel.tagTitle = object.val
                                    viewModel.selectedTag = key
                                }
                                viewModel.showTagDrop = false
                            }
                            ForEach(items2) { (item : BuildCD) in
                                Button {
                                    viewModel.expanseBuild = item
                                    } label: {
                                        Text(item.title! + " " + item.tag!)
                                        
                                    }
                            }
                            Button {
                                viewModel.expanseBuild = nil
                                } label: {
                                    Text("!BEZ BUDOWY!")
                                    
                                }
                            
                            
                            Button(action: { viewModel.attachImage() }, label: {
                                HStack {
                                    Image(systemName: "paperclip")
                                        .font(.system(size: 18.0, weight: .bold))
                                        .foregroundColor(Color.text_secondary_color)
                                        .padding(.leading, 16)
                                    TextView(text: "Załącz zdjęcie", type: .button).foregroundColor(Color.text_secondary_color)
                                    Spacer()
                                }
                            })
                            .frame(height: 50).frame(maxWidth: .infinity)
                            .background(Color.secondary_color)
                            .cornerRadius(4)
                            .actionSheet(isPresented: $showAttachSheet) {
                                ActionSheet(title: Text("Czy chcesz usunąć załącznik?"), buttons: [
                                    .default(Text("Usuń")) { viewModel.removeImage() },
                                    .cancel()
                                ])
                            }
                            
                            if let image = viewModel.imageAttached {
                                Button(action: { showAttachSheet = true }, label: {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 250).frame(maxWidth: .infinity)
                                        .background(Color.secondary_color)
                                        .cornerRadius(4)
                                })
                            }
                            
                     //      Spacer().frame(height: 150)
                            
                        }}
                        .frame(maxWidth: .infinity).padding(.horizontal, 8)
                        .alert(isPresented: $viewModel.showAlert,
                               content: { Alert(title: Text(APP_NAME), message: Text(viewModel.alertMsg), dismissButton: .default(Text("OK"))) })
                    
                    
                }.edgesIgnoringSafeArea(.top)
                .padding()
                
                VStack {
                    
                    Spacer()
                    VStack {
                        
                        Button(action: { viewModel.saveTransaction(managedObjectContext: managedObjectContext) }, label: {
                            HStack {
                                Spacer()
                                TextView(text: viewModel.getButtText(), type: .button).foregroundColor(.white)
                                Spacer()
                            }
                        })
                        .padding(.vertical, 12).background(Color.main_color).cornerRadius(8)
                        
                    }.padding(.bottom, 16).padding(.horizontal, 8)
                    
                }
                
            }
            .navigationBarHidden(true)
        }
     //   .dismissKeyboardOnTap()
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onReceive(viewModel.$closePresenter)
        { close in
            if close { self.presentationMode.wrappedValue.dismiss() }
        }
        }}
    
}
/*
struct AddBuildExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddBuildExpenseView()
    }
}
*/
