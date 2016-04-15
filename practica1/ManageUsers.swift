//
//  ManageUsers.swift
//  practica1
//
//  Created by Javier Arguello on 14/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import Foundation
class ManageUsers{
    init(){
        //init code
    }
    func registerUser(email: String, password: String, username: String, name: String) -> Bool{
        let backendless = Backendless.sharedInstance()
        let user: BackendlessUser = BackendlessUser()
        user.email = email
        user.password = password
        backendless.userService.registering(user, response: { (registeredUser) -> Void in
            // Código en caso de registro correcto
            let email = registeredUser.email
            print("Usuario \(email) registrado correctamente")},
            error: { (error) -> Void in
            // Código en caso de error en el registro
            let message = error.message
            print("Error registrando al usuario: \(message)")
            
            })
        return true
    }
    
}