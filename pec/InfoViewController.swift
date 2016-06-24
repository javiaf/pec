//
//  InfoViewController.swift
//  practica1
//
//  Created by Javier Arguello on 15/4/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var sitiosTextField: UITextField!
    @IBOutlet weak var usersTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let users = findUsers();
        usersTextField.enabled = false;
        usersTextField.text = "\(users)";
        let sitios = findSitios();
        sitiosTextField.enabled = false;
        sitiosTextField.text = "\(sitios)";
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func findUsers() -> Int{
        
        let dataQuery = BackendlessDataQuery()
        
        var error: Fault?
        let bc = Global.backendless.data.of(BackendlessUser.ofClass()).find(dataQuery, fault: &error)
        if error == nil {
            print("Users have been found: \(bc.data)")
            return bc.data.count;
        }
        else {
            print("Server reported an error: \(error)")
            return 0;
        }
    }
    
    func findSitios() -> Int{
        
        let dataQuery = BackendlessDataQuery()
        
        var error: Fault?
        let bc = Global.backendless.data.of(Sitio.ofClass()).find(dataQuery, fault: &error)
        if error == nil {
            print("Sitios have been found: \(bc.data)")
            return bc.data.count;
        }
        else {
            print("Server reported an error: \(error)")
            return 0;
        }
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
