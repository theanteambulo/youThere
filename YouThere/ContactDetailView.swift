//
//  ContactDetailView.swift
//  YouThere
//
//  Created by Jake King on 10/09/2021.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContactDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var displayDeleteContactAlert = false
    @State private var contactLocationDetails = [CodableMKPointAnnotation]()
    @State private var contactCoordinateAnnotation: MKPointAnnotation?
    @State private var displayContactLocationDetails = false
    
    let contact: Contact
    let contacts: Contacts
    let image: Image?
    
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
                            Image(systemName: "person")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding(.bottom,
                                         5)
                        }
                    }
                }
                
                VStack {
                    Text("\(contact.firstName) \(contact.lastName)")
                        .font(.title.bold())
                    
                    Text("\(contact.description)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    MapView(centerCoordinate: CLLocationCoordinate2D(latitude: contact.locationLatitude,
                                                                     longitude: contact.locationLongitude),
                            contactLocationPin: $contactCoordinateAnnotation,
                            showingPlaceDetails: $displayContactLocationDetails,
                            annotations: contactLocationDetails)
                        .frame(width: 400,
                               height: 550)
                }
            }
            .onAppear(perform: getContactLocation)
        }
        .navigationBarItems(trailing: Button(action: {
            self.displayDeleteContactAlert = true
        }) {
            Image(systemName: "trash")
        })
        .alert(isPresented: $displayDeleteContactAlert) {
            Alert(title: Text("Are you sure?"),
                  message: Text("Are you sure you want to delete \(contact.firstName) as a contact?"),
                  primaryButton: .destructive(Text("Delete")) {
                    self.deleteContact()
                  },
                  secondaryButton: .cancel())
        }
    }
    
    func deleteContact() {
        if let contactToDeleteIndex = contacts.contacts.firstIndex(where: {$0.id == self.contact.id}) {
            print("Contact to delete: \(contacts.contacts[contactToDeleteIndex])")
            contacts.contacts.remove(at: contactToDeleteIndex)
            print("Contact deleted.")
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func getContactLocation() {
        let location = CodableMKPointAnnotation()
        location.title = contact.meetingPlace
        location.subtitle = contact.eventDetails
        location.coordinate = CLLocationCoordinate2D(latitude: self.contact.locationLatitude,
                                                     longitude: self.contact.locationLongitude)
        
        self.contactCoordinateAnnotation = location
        self.contactLocationDetails.append(location)
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static let firstName = "first"
    static let lastName = "last"
    static let description = "description"
    static let meetingPlace = "place"
    static let eventDetails = "details"
    
    static var previews: some View {
        let contact = Contact(firstName: firstName,
                              lastName: lastName,
                              description: description,
                              imageId: UUID(),
                              locationLatitude: 0,
                              locationLongitude: 0,
                              meetingPlace: meetingPlace,
                              eventDetails: eventDetails)

        return ContactDetailView(contact: contact,
                                 contacts: Contacts(),
                                 image: Image("whistler-blackcomb"))
    }
}
