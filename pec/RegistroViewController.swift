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
    
    @IBOutlet weak var nameOutlet: UITextField!
    @IBOutlet weak var userOutlet: UITextField!
    @IBOutlet weak var termsSwitch: UISwitch!
    @IBOutlet weak var pass2Outlet: UITextField!
    @IBOutlet weak var passOutlet: UITextField!
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func registerUser(email: String, password: String, username: String, name: String) -> Bool{

        let user: BackendlessUser = BackendlessUser()
        user.email = email
        user.password = password
        user.addProperties(["user" : username, "name": name])
        Global.backendless.userService.registering(user, response: { (registeredUser) -> Void in
            // Código en caso de registro correcto
            let email = registeredUser.email
            self.showAlert("Registro",message: "Usuario con email: \(email) registrado correctamente")
            print("Usuario \(user) registrado correctamente")},
            error: { (error) -> Void in
                // Código en caso de error en el registro
                let message = error.message
                self.showAlert("Error de registro",message: error.message)
                print("Error registrando al usuario: \(message)")
                
        })
        return true
    }
    
    
    @IBAction func registroButton(sender: UIButton) {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        indicador.startAnimating()
        print("Registro")
        if(checkSwitch() && checkPassword() && checkEmail() && checkName() && checkUser()){
            if let email = emailOutlet.text{
                registerUser(email, password:passOutlet.text!,username:userOutlet.text!,name:nameOutlet.text!)
            }
        }
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        indicador.stopAnimating()
    }
    func checkSwitch() -> Bool{
        if termsSwitch.on{
            print("Terms accepted")
            return true
        }
        print("Terms not accepted")
        showAlert("Terminos y Condiciones",message: "Has de aceptar los términos y condiciones")
        return false
    }
    func checkUser() ->Bool{
    if let user = userOutlet.text{
        if !user.isEmpty{
            return true
        }
        }
    showAlert("User",message: "El username se encuentra vacío")
    return false
    }
    func checkEmail() ->Bool{
        if let email = emailOutlet.text{
            if !email.isEmpty{
                return true
            }
        }
        showAlert("Email",message: "El email se encuentra vacío")
        return false
    }
    
    func checkName() ->Bool{
        if let name = nameOutlet.text{
            if !name.isEmpty{
                return true
            }
        }
        showAlert("Nombre Completo",message: "El Nombre Completo se encuentra vacío")
        return false
    }

    func checkPassword() ->Bool{
        if let pass = passOutlet.text{
            if let pass2 = pass2Outlet.text{
                if !pass.isEmpty && !pass2.isEmpty && pass==pass2{
                    return true
                }
            }
            
        }
        showAlert("Password",message: "Los passwords introducidos no coinciden o se encuentran vacíos")
        return false
    }

    func showAlert(title: String,message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.indicador.center = self.view.center
        self.indicador.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleWidth, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleBottomMargin]
        self.indicador.hidesWhenStopped = true
        self.indicador.activityIndicatorViewStyle = .WhiteLarge
        self.indicador.color = UIColor.clearColor()
        self.view.addSubview(self.indicador)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
