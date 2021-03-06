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
    private var indicador: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBAction func loginButton(sender: UIButton) {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        indicador.startAnimating()
        let user = userOutlet.text!
        let password = passOutlet.text!
        //let backendless = Backendless.sharedInstance()
        Global.backendless.userService.login(user, password: password, response: { (logedInUser) -> Void in
                // Código en caso de login correcto
                let email = logedInUser.email
                print("Hola \(email)")
                Global.email = logedInUser.email
                Global.userName = logedInUser.getProperty("user") as! String
                Global.nombreCompleto = logedInUser.getProperty("name") as! String
                self.performSegueWithIdentifier("LoginToNavigation", sender: sender)},
            error: { (error) -> Void in
                // Código en caso de error en el login
                let message = error.message
                print("Error en login: \(message)")
                self.showAlert("Error de logado", message: message)
            })
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        indicador.stopAnimating()
    }

    func showAlert(title: String,message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Global.email=""
        Global.nombreCompleto=""
        Global.userName=""
        self.indicador.center = self.view.center
        self.indicador.autoresizingMask = [.FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleWidth, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleBottomMargin]
        self.indicador.hidesWhenStopped = true
        self.indicador.activityIndicatorViewStyle = .WhiteLarge
        self.indicador.color = UIColor.clearColor()
        self.view.addSubview(self.indicador)
        // Do any additional setup after loading the view, typically from a nib.
    }
    @IBAction func imageTapped(sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = .blackColor()
        newImageView.contentMode = .ScaleAspectFit
        newImageView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "dismissFullscreenImage:")
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
    }
    
    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

