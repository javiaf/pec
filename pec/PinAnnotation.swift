//
//  PinAnnotation.swift
//  pec
//
//  Created by Javier Arguello on 23/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import MapKit
import Foundation
import UIKit

class PinAnnotation : NSObject, MKAnnotation {
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return coord
        }
    }
    var number: Int?
    var title: String? = ""
    var subtitle: String? = ""
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        self.coord = newCoordinate
    }
}