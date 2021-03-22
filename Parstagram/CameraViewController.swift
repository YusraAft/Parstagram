//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Mac User on 3/21/21.
//

import UIKit
import AlamofireImage
import Parse // this is where the PF object comes from

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    //once pic taken it says call me back with function to give me the image

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var commentField: UITextField!
    
    @IBAction func onSubmitButton(_ sender: Any) {
        
        //example dog walking app with table of pets because each app has main tables for its main functions like statuses, comments, users, etc.
        let post = PFObject(className: "Pets")//dictionary like
        
        post["caption"] = commentField.text!
        post["author"] = PFUser.current()!
        
        let imageData = imageView.image!.pngData() //saved as png
        let file = PFFileObject(data: imageData!)//saved in a sep table for photos  and then the col below will have the url for this -> handled by parse
        
        post["image"] = file
        //not in parse yet every PF object can save itself
        //schema _> which colseach table will have
        post.saveInBackground {(success, error) in
            if success{
                self.dismiss(animated: true, completion: nil)
                print("saved!")
            } else{
                print("error!")
            }
        }
    }
    
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self //when user done with photo call me bck
        picker.allowsEditing = true //user can edit
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) //swift enums youc an start with dot and it figures out hich enum you are expecting
        {
            picker.sourceType = .camera
        }
        else{
            //since simulator does not have the camera
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage //want to resize because heroku limit
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
