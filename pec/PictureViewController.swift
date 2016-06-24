//
//  PictureViewController.swift
//  practica2
//
//  Created by Javier Arguello on 22/5/16.
//  Copyright © 2016 uoc. All rights reserved.
//

protocol PictureViewControllerDelegate: class {
    func returnImage(image: UIImage)
}

import UIKit



class PictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func addBtn(sender: UIButton) {
            dismissSelf()
        
    }

    @IBAction func selectBtn(sender: AnyObject) {
        let picker : UIImagePickerController = UIImagePickerController();
        picker.delegate = self;
        picker.allowsEditing = true;
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
        self.presentViewController(picker, animated: true, completion: nil);
    }
    @IBAction func takeBtn(sender: AnyObject) {
        if (!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            showAlert("Error en Cámara", message: "No ha sido posible acceder a la cámara del dispositivo");
        }
        else
        {
            let picker : UIImagePickerController = UIImagePickerController();
            picker.delegate = self;
            picker.allowsEditing = true;
            picker.sourceType = UIImagePickerControllerSourceType.Camera;
            self.presentViewController(picker, animated: true, completion: nil);
        }
    }
    
    weak var delegate: PictureViewControllerDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage: UIImage = info[UIImagePickerControllerEditedImage] as! UIImage;
        self.imageView.image = chosenImage;
        picker.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func showAlert(title: String,message: String) {
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func dismissSelf()
    {
        if let imagen = imageView.image{
            self.delegate?.returnImage(imagen);
        }
        self.dismissViewControllerAnimated(true, completion: nil);
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
