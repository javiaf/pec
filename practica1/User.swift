//
//  User.swift
//  practica1
//
//  Created by Javier Arguello on 15/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
class User{
    var email = ""
    var nombreCompleto = ""
    var userName = ""
    init(email:String, nombreCompleto:String, userName: String){
        self.email=email
        self.nombreCompleto=nombreCompleto
        self.userName=userName
    }
}