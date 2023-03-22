//
//  AboutView.swift
//  Expenso
//
//  Created by Sameer Nawaz on 31/01/21.
//

import SwiftUI
import CoreData
struct AboutView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @FetchRequest(
        entity: WorkerCD.entity(),
        sortDescriptors: [NSSortDescriptor(key: "occuredOn", ascending: true)]
      ) var items: FetchedResults<WorkerCD>
    
    // CoreData
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject private var viewModel = ExpenseSettingsViewModel()
    var body: some View {
        
        
        
        NavigationView {
            ZStack {
                Color.primary_color.edgesIgnoringSafeArea(.all)
                
                VStack {
                    ToolbarModelView(title: "Pracownicy") { self.presentationMode.wrappedValue.dismiss() }
                    
                    
                    
                    
                    ScrollView(.vertical){
                        
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 30),count: 3), content:{
                    ForEach(items) { (item : WorkerCD) in
                       /* NavigationLink(destination: WorkerDetailedView(workerObj: item)*/
                        NavigationLink(destination: NavigationLazyView(WorkerExpanse( worker: item)), label: {
                                        VStack{
                            
                            /*
                            Image()
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 250, height: 250)
                                .cornerRadius(10)
                            */
                                            ZStack(){
                                                
                                            
                            if let data = item.imageAttached {
                                
                                    Image(uiImage: UIImage(data: data)!)
                                        
                                        .resizable()
                                       
                                        .scaledToFill()
                                        .frame(maxHeight: 500).frame(maxWidth: 600)
                                        .background(Color.secondary_color)
                                        .cornerRadius(7)
                            }
                            else{
                                Image("images")
                                    .resizable()
                                    
                                    .scaledToFill()
                                    .frame(maxHeight: 500).frame(maxWidth: 600)
                                    .background(Color.secondary_color)
                                    .cornerRadius(7)
                                
                            }
                                                
                                                HStack{
                                                    
                                                Button(action: { viewModel.exportTransactionsLast(moc: managedObjectContext, worker: item) }, label: {
                                                    HStack {
                                                        
                                                        Image(uiImage: UIImage(systemName: "printer")!).resizable()
                                                        
                                                            
                                                        
                                                    }.frame(maxWidth: 70.0, maxHeight: 70.0)
                                                }).padding().background(Color.red).cornerRadius(5)
                                                    //Text("Last month")
                                                    Button(action: { viewModel.exportTransactions(moc: managedObjectContext, worker: item)}, label: {
                                                    HStack {
                                                        
                                                        Image(uiImage: UIImage(systemName: "printer")!).resizable()
                                                        
                                                    }.frame(maxWidth: 70.0, maxHeight: 70.0)
                                                       // Text("That month")
                                                }).padding().background(Color.red).cornerRadius(5)
                                                    Button(action: { viewModel.exportTransactionsAll(moc: managedObjectContext, worker: item) }, label: {
                                                        HStack {
                                                            
                                                            Image(uiImage: UIImage(systemName: "printer")!).resizable()
                                                            
                                                            
                                                        }.frame(maxWidth: 70.0, maxHeight: 70.0)
                                                    }).padding().background(Color.red).cornerRadius(5)
                                                       // Text("All transactions from worker")
                                                }}
                                            
                            HStack{
                                
                                // Use Your Own Post Model Data Here....
                               /* NavigationLink(destination: NavigationLazyView(WorkerExpanse()), isActive: $displayWorkerExpanse, label: {})*/
                                
                                Text(item.name! + " " + item.surname!)
                                    .foregroundColor(.white)
                                Spacer(minLength: 0)
                                
                                Button(action: {}, label: {
                                    
                                    Label(
                                        title: { Text("Zarobki na h: " + String(item.amount) + " PLN") },
                                        icon: { Image(systemName: "suit.hear") })
                                        
                                })
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {}, label: {
                                    
                                    Label(
                                        title: { Text(String("Notatka: " + item.note!)) },
                                        icon: { Image(systemName: "message") })
                                })
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal)
                            .foregroundColor(.gray)
                        }})
                        
                    }
                    
                    .padding()
                    //.scaledToFill()
                        
                    })
                    Spacer()
                    }}
                    
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: NavigationLazyView(AddExpenseView(viewModel: AddExpenseViewModel())),
                                       label: { Image("plus_icon").resizable().frame(width: 32.0, height: 32.0) })
                        .padding().background(Color.main_color).cornerRadius(35)
                        NavigationLink(destination: NavigationLazyView(AddWorkerView(viewModel: AddWorkerViewModel())),
                                       label: { Image("plus_icon").resizable().frame(width: 32.0, height: 32.0) })
                        .padding().background(Color.red).cornerRadius(35)
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
/*
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
*/
