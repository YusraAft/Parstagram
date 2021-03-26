//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Mac User on 3/21/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var posts = [PFObject]() // instantiated empty array
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)//everytime you finish compsing want tableview to refresh so to pull newest
        let query = PFQuery(className:"Posts")
        query.includeKey("author") //if you don't add include key, it will only go to pointer and not to the actual item
        query.limit = 20 //last 20
        query.findObjectsInBackground{(posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        
        let post = posts[indexPath.row] //the row stuff colects the particular post
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af_setImage(withURL: url)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]//row that I selected
        //comment object
        let comment = PFObject(className: "Comments") //will autocreate this columns
        comment["text"] = "This is random comment"
        comment["post"] = post //which post does it belong to
        comment["author"] = PFUser.current()!
        //can always put in more cols later
        
        post.addUniqueObject(comment, forKey: "comments")//for every post I htink there is an array called comments and I want to add this comment to the array
        //now save the post
        post.saveInBackground{
            (success, error) in
            if success{
                print("Comment Saved")
            } else{
                print("Error saving Comment")
            }
        }
    }//everytime user taps pic then it calls this code
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func onLogOut(_ sender: Any) {
        
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        //UIApplication.shared.delegate as! AppDelegate
        
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate; delegate.window?.rootViewController = loginViewController
        //when you logout it switches to the login screen aka loginiewcontroller
    }
    
    
    
}
