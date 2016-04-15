//
//  ViewController.swift
//  practica1
//
//  Created by Javier Arguello on 12/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var userOutlet: UITextField!
    @IBOutlet weak var passOutlet: UITextField!
    @IBAction func loginButton(sender: UIButton) {
        let email = userOutlet.text!
        let password = passOutlet.text!
        let backendless = Backendless.sharedInstance()
        backendless.userService.login(email, password: password, response: { (logedInUser) -> Void in
            // Código en caso de login correcto
            let email = logedInUser.email
            print("Hola \(email)")
            self.performSegueWithIdentifier("LoginToNavigation", sender: sender)},
            error: { (error) -> Void in
            // Código en caso de error en el login 
            let message = error.message
            print("Error en login: \(message)")
            })
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

