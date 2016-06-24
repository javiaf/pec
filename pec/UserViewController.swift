//
//  UserViewController.swift
//  practica1
//
//  Created by Javier Arguello on 15/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        userField.enabled=false
        userField.text=Global.userName
        nameField.enabled=false
        nameField.text=Global.nombreCompleto
        emailField.enabled=false
        emailField.text=Global.email
        self.navigationController!.title = "Perfil"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
