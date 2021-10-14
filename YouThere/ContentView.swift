//
//  ContentView.swift
//  YouThere
//
//  Created by Jake King on 09/09/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var contacts = Contacts()
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var displayAddNewContactSheet = false
    @State private var contactImagesDict = [UUID: UIImage]()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(self.contacts.contacts.sorted()) { contact in
                        NavigationLink(destination: ContactDetailView(contact: contact,
                                                                      contacts: self.contacts,
                                                                      image: getContactImage(contact))) {
                            HStack {
                                VStack {
                                    if getContactImage(contact) != nil {
                                        getContactImage(contact)?
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50,
                                                   height: 50)
                                            .clipShape(Circle())
                                    } else {
                                        ZStack {
                                            Circle()
                                                .frame(width: 50,
                                                       height: 50)
                                                .foregroundColor(.gray)
                                            
                                            Image(systemName: "person")
                                                .font(.title)
                                                .foregroundColor(.white)
                                                .padding(.bottom,
                                                         5)
                                        }
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("\(contact.firstName) \(contact.lastName)")
                                        .font(.headline)
                                    Text("\(contact.description == "" ? "No further information available." : contact.description)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete(perform: self.deleteContact)
                    .onAppear(perform: {
                        getImages(self.contacts.contacts)
                    })
                }
            }
            .navigationBarTitle("YouThere")
            .navigationBarItems(leading: EditButton(),
                                trailing: Button(action: {
                                    self.displayAddNewContactSheet = true
                                }) {
                                    Image(systemName: "plus")
                                        .font(.title3)
                                })
        }
        .sheet(isPresented: $displayAddNewContactSheet) {
            AddNewContactView(contacts: self.contacts)
        }
    }
    
    func deleteContact(at offsets: IndexSet) {
        self.contacts.contacts.remove(atOffsets: offsets)
        print("Number of contacts: \(contacts.contacts.count)")
    }
    
    func getImages(_ contacts: [Contact]) {
        for contact in contacts {
            if Storage.fileExists("\(contact.imageId).json",
                                  in: .documents) == true {

                let jpegData = Storage.retrieve("\(contact.imageId).json",
                                                from: .documents,
                                                as: Data.self)

                if let uiImage = UIImage(data: jpegData) {
                    contactImagesDict[contact.imageId] = uiImage
                }
            }
        }
    }
    
    func getContactImage(_ contact: Contact) -> Image? {
        if contactImagesDict[contact.imageId] != nil {
            return Image(uiImage: contactImagesDict[contact.imageId]!)
        }
        
        return nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
