//
//  Sitio.swift
//  practica2
//
//  Created by Javier Arguello on 17/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
import UIKit

class Sitio : NSObject {
    var objectId : String?
    var ownerId: String?
    var nombre: String?
    var descripcion: String?
    var fotos: [Foto] = []
    var coordinates: GeoPoint?
    var valoraciones : [Valoracion] = []
}