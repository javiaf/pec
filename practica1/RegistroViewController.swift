//
//  RegistroViewController.swift
//  practica1
//
//  Created by Javier Arguello on 15/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit
class RegistroViewController: UIViewController {

    @IBOutlet weak var emailOutlet: UITextField!
    
    @IBOutlet weak var termsSwitch: UISwitch!
    @IBOutlet weak var pass2Outlet: UITextField!
    @IBOutlet weak var passOutlet: UITextField!
    @IBAction func registroButton(sender: UIButton) {
        print("Registro")
        if(checkPassword() && checkSwitch()){
            if let email = emailOutlet.text{
        let manageUsers=ManageUsers()
                manageUsers.registerUser(email, password:passOutlet.text!,username:"",name:"")
            }
        }
    }
    func checkSwitch() -> Bool{
        if termsSwitch.on{
            print("Terms accepted")
            return true
        }
        print("Terms not accepted")
        return false
    }
    func checkPassword() ->Bool{
        if let pass = passOutlet.text{
            if let pass2 = pass2Outlet.text{
                if pass==pass2{
                    return true
                }
            }
            
        }
        return false
    }
    override func viewDidLoad() {
        super.viewDidLoad()

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
