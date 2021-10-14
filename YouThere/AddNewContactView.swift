//
//  AddNewContactView.swift
//  YouThere
//
//  Created by Jake King on 10/09/2021.
//

import SwiftUI
import CoreLocation

struct AddNewContactView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var contacts: Contacts
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var description = ""
    @State private var displayImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var contactLocation: CLLocationCoordinate2D? // split this out into latitude and longitude
    @State private var displayMissingDataAlert = false
    @State private var saveContactLocation = false
    @State private var meetingPlace = ""
    @State private var eventDetails = ""
    
    var fieldsValid: Bool {
        let firstNameInvalid = firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let lastNameInvalid = lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        if (firstNameInvalid || lastNameInvalid) {
            return false
        } else {
            return true
        }
    }
    
    var missingFieldsString: String {
        var missingFields = [String]()
        let firstNameInvalid = firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let lastNameInvalid = lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        if firstNameInvalid {
            missingFields.append("first name")
        }
        
        if lastNameInvalid {
            missingFields.append("last name")
        }
        
        if missingFields.count == 0 {
            return ""
        } else if missingFields.count == 1 {
            return missingFields[0]
        } else {
            return "\(missingFields[0]) and a \(missingFields[1])"
        }
    }
    
    let locationFetcher = LocationFetcher()
    
    var body: some View {
        NavigationView {
            VStack {
                if image != nil {
                    image?
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 220,
                               height: 220)
                        .clipShape(Circle())
                } else {
                    ZStack {
                        Circle()
                            .frame(width: 220,
                                   height: 220)
                            .foregroundColor(.gray)
                        
                        VStack {
                            Image(systemName: "camera")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(.bottom,
                                         5)
                            
                            Text("Select a photo")
                                .foregroundColor(.white)
                        }
                    }
                    .onTapGesture {
                        self.displayImagePicker = true
                    }
                }
                
                Form {
                    TextField("First name",
                              text: $firstName)
                    
                    TextField("Last name",
                              text: $lastName)
                    
                    TextField("Say something about \(firstName)...",
                              text: $description)
                    
                    TextField("Where did you meet?",
                              text: $meetingPlace)
                    
                    TextField("Further details about this event...",
                              text: $eventDetails)
                    
                    Toggle(isOn: self.$saveContactLocation) {
                        Text("Save contact location")
                    }
                    .onChange(of: saveContactLocation) { value in
                        print("Permission to save contact location: \(saveContactLocation)")
                        if saveContactLocation == true {
                            self.locationFetcher.start()
                        }
                    }
                }
            }
            .navigationBarTitle("Add a new contact")
            .navigationBarItems(trailing: Button("Save") {
                if fieldsValid {
                    let imageId = UUID()
                    
                    if saveContactLocation == true {
                        if let location = self.locationFetcher.lastKnownLocation {
                            contactLocation = location
                            print("Contact's location is: \(contactLocation ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))")
                        } else {
                            print("Contact's location unknown")
                        }
                    } else {
                        print("Permission to save the user's location denied")
                    }
                    
                    let newContact = Contact(firstName: self.firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                                             lastName: self.lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                                             description: self.description.trimmingCharacters(in: .whitespacesAndNewlines),
                                             imageId: imageId,
                                             locationLatitude: contactLocation?.latitude ?? 0,
                                             locationLongitude: contactLocation?.longitude ?? 0,
                                             meetingPlace: self.meetingPlace.trimmingCharacters(in: .whitespacesAndNewlines),
                                             eventDetails: self.eventDetails.trimmingCharacters(in: .whitespacesAndNewlines)
                                             )
                    
                    self.contacts.contacts.append(newContact)
                    self.contacts.contactImagesDict[newContact.imageId] = self.inputImage
                    saveImage(inputImage,
                              contact: newContact)
                    
                    self.presentationMode.wrappedValue.dismiss()
                } else {
                    self.displayMissingDataAlert = true
                }
            })
            .sheet(isPresented: $displayImagePicker,
                   onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .alert(isPresented: $displayMissingDataAlert) {
                Alert(title: Text("Whoops!"),
                      message: Text("Looks like your new contact is missing some info. Please give them a \(missingFieldsString)."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func saveImage(_ chosenImage: UIImage?,
                   contact: Contact) {
        if let jpegData = chosenImage?.jpegData(compressionQuality: 0.8) {
            Storage.store(jpegData,
                          to: .documents,
                          as: "\(contact.imageId).json")
        }
    }
    
    func loadImage() {
        guard let uiImg = inputImage else {
            return
        }
        
        image = Image(uiImage: uiImg)
    }
}

struct AddNewContactView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewContactView(contacts: Contacts())
    }
}
