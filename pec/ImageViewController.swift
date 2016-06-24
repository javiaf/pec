//
//  ImageViewController.swift
//  pec
//
//  Created by Javier Arguello on 24/6/16.
//  Copyright © 2016 uoc. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var selectedImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = selectedImage;
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var imageView: UIImageView!
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