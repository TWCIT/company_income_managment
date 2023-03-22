//
//  BuildView.swift
//  Expenso
//
//  Created by Marek Wala on 26/04/2021.
//


import SwiftUI
import CoreData
struct BuildView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @FetchRequest(
        entity: BuildCD.entity(),
        sortDescriptors: [NSSortDescriptor(key: "occuredOn", ascending: true)]
      ) var items: FetchedResults<BuildCD>
    
    // CoreData
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject private var viewModel = ExpenseSettingsViewModel()
    var body: some View {
        
        
        
        NavigationView {
            ZStack {
                Color.primary_color.edgesIgnoringSafeArea(.all)
                
                VStack {
                    ToolbarModelView(title: "Budowa") { self.presentationMode.wrappedValue.dismiss() }
                    
                    
                    
                    
                    ScrollView(.vertical){
                        
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15),count: 3), content:{
                    ForEach(items) { (item : BuildCD) in
                       // NavigationLink(destination: BuildDetailedView(buildObj: item)
                        NavigationLink(destination: NavigationLazyView(BuildExpanse( build: item)), label: {
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
                                        .frame(height: 450).frame(maxWidth: .infinity)
                                        .background(Color.secondary_color)
                                        .cornerRadius(7)
                            }
                            else{
                                Image("house_photo")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 450).frame(maxWidth: .infinity)
                                    .background(Color.secondary_color)
                                    .cornerRadius(7)
                            }
                                                HStack{
                                                /*
                                                Button(action: { viewModel.exportTransactions(moc: managedObjectContext) }, label: {
                                                    HStack {
                                                        
                                                        Image(uiImage: UIImage(systemName: "printer")!).resizable()
                                                        
                                                            
                                                        
                                                    }.frame(width: 70.0, height: 70.0)
                                                }).padding().background(Color.red).cornerRadius(35)
                                                
                                                Button(action: { viewModel.exportTransactions(moc: managedObjectContext) }, label: {
                                                    HStack {
                                                        
                                                        Image("plus_icon").resizable()
                                                        
                                                    }.frame(width: 70.0, height: 70.0)
                                                }).padding().background(Color.red).cornerRadius(35)
                                                */
                                                }
 
 }
                                            
                            HStack{
                                
                                // Use Your Own Post Model Data Here....
                                
                                
                                Text(item.title! + " " + item.tag!)
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
                        
                    })
                    Spacer()
                    }}.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: NavigationLazyView(AddBuildExpenseView(viewModel: AddBuildExpenseViewModel())),
                                       label: { Image("plus_icon").resizable().frame(width: 32.0, height: 32.0) })
                        .padding().background(Color.main_color).cornerRadius(35)
                        NavigationLink(destination: NavigationLazyView(AddBuildView(viewModel: AddBuildViewModel())),
                                       label: { Image("plus_icon").resizable().frame(width: 32.0, height: 32.0) })
                        .padding().background(Color.green).cornerRadius(35)
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
