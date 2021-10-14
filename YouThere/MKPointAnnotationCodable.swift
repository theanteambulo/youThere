//
//  MKPointAnnotationCodable.swift
//  YouThere
//
//  Created by Jake King on 21/09/2021.
//

import MapKit

class CodableMKPointAnnotation: MKPointAnnotation, Codable {
    enum CodingKeys: CodingKey {
        case title, longitude, latitude
    }
    
    override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self,
                                     forKey: .title)
        let longitude = try container.decode(CLLocationDegrees.self,
                                              forKey: .longitude)
        let latitude = try container.decode(CLLocationDegrees.self,
                                            forKey: .latitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude,
                                            longitude: longitude)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title,
                             forKey: .title)
        try container.encode(coordinate.longitude,
                             forKey: .longitude)
        try container.encode(coordinate.latitude,
                             forKey: .latitude)
    }
}
