//
//  Contact.swift
//  YouThere
//
//  Created by Jake King on 09/09/2021.
//

import Foundation
import SwiftUI
import CoreLocation

struct Contact: Codable, Identifiable, Comparable {
    let id: UUID
    let firstName: String
    let lastName: String
    let description: String
    let imageId: UUID
    let locationLatitude: Double
    let locationLongitude: Double
    let meetingPlace: String
    let eventDetails: String
    
    init(firstName: String,
         lastName: String,
         description: String,
         imageId: UUID,
         locationLatitude: Double,
         locationLongitude: Double,
         meetingPlace: String,
         eventDetails: String) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.description = description
        self.imageId = imageId
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
        self.meetingPlace = meetingPlace
        self.eventDetails = eventDetails
    }
    
    static func < (lhs: Contact,
                   rhs: Contact) -> Bool {
        lhs.lastName < rhs.lastName
    } 
}

class Contacts: ObservableObject {
    @Published var contacts = [Contact]() {
        didSet {
            // replace the current array of contacts
            Storage.store(contacts,
                          to: .documents,
                          as: "contacts.json")
        }
    }
    
    @Published var contactImagesDict = [UUID: UIImage]()
    
    init() {
        if !Storage.fileExists("contacts.json",
                               in: .documents) {
            self.contacts = []
            print("Number of contacts: \(self.contacts.count)")
        }
        
        self.contacts = Storage.retrieve("contacts.json",
                                         from: .documents,
                                         as: [Contact].self)
        return
    }
}
