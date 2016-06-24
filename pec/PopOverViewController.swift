//
//  PopOverViewController.swift
//  pec
//
//  Created by Javier Arguello on 23/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

protocol PopOverViewControllerDelegate: class {
    func refreshValoracion()
}

class PopOverViewController: UIViewController {

    var sitio : Sitio?
    weak var delegate: PopOverViewControllerDelegate?
    @IBOutlet weak var valoracionOutlet: FloatRatingView!
    @IBAction func valorar(sender: AnyObject) {
        var found = false
        if sitio != nil{
            for valoracion in sitio!.valoraciones{
                if valoracion.userId == Global.backendless.userService.currentUser.objectId{
                    found = true
                    valoracion.valoracion = valoracionOutlet.rating
                }
            }
        }
        if !found{
            let valoracion : Valoracion = Valoracion()
            valoracion.userId = Global.backendless.userService.currentUser.objectId;
            valoracion.valoracion = valoracionOutlet.rating
            sitio!.valoraciones += [valoracion]
        }
        updateSite()
        self.delegate?.refreshValoracion();
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    func updateSite() {
        let dataStore = Global.backendless.data.of(Sitio.ofClass());
        var error: Fault?
        let result = dataStore.save(sitio, fault: &error) as? Sitio
        if error == nil {
            print("Site has been updated")
        }
        else {
            print("Server reported an error: \(error)")
        }
        /* dataStore.save(
         sitio,
         response: { (result: AnyObject!) -> Void in
         print("Site has been updated")
         },
         error: { (fault: Fault!) -> Void in
         print("fServer reported an error: \(fault)")
         })*/
        
    }
    override func viewDidLoad() {
        
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