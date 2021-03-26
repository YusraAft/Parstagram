//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Mac User on 3/21/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate{
    
    @IBOutlet var tableView: UITableView!
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    
    var posts = [PFObject]() // instantiated empty array
    var selectedPost: PFObject! //! because only optionals can be nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentBar.inputTextView.placeholder = "Add a Comment ..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self //delegate anytime you have soething that can fire events
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        tableView.keyboardDismissMode = .interactive
        //can dimiss keyboard by dragging down
        //use the notification cnete rlike post office that broadcats all notifcations
        let center = NotificationCenter.default
        //whenever x y z happens then notify me
        center.addObserver(self, selector: #selector(keyboardWillBHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        //call this current object which is self with the selector fucntion and the notifcaiton name
        //grab the post ffcie notifciation center say whe the keyboardwill hide then call the given function
        
    }
    
    @objc func keyboardWillBHidden(note: Notification){
        //this fucntion will be called when keyboard is hiding
        commentBar.inputTextView.text = nil //clear out everything when keyboard dismissed
        
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    //these two vars below are "hacking" the framework
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)//everytime you finish compsing want tableview to refresh so to pull newest
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author", "comments", "comments.text", "comments.author"])
                           //if you don't add include key, it will only go to pointer and not to the actual item
        query.limit = 20 //last 20
        query.findObjectsInBackground{(posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //create the comment
        
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost //which post does it belong to
        comment["author"] = PFUser.current()!
        //can always put in more cols later

        selectedPost.addUniqueObject(comment, forKey: "comments")//for every post I htink there is an array called comments and I want to add this comment to the array
        //now save the post
        selectedPost.saveInBackground{(success, error) in
            if success{
                print("Comment Saved")
            } else{
                print("Error saving Comment")
            }
        }
        tableView.reloadData() //numb of rows and num of cols need to be refreshed
        //clear and dismiss the input bar
        //this fucntion will be called when keyboard is hiding
        commentBar.inputTextView.text = nil //clear out everything when keyboard dismissed
        
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? [] //?? says if left is nil then set equal to the right
        //because the left side is an optional
        return comments.count + 2 //1 pic and 1 to have a comment
        
        //return posts.count //plus number of comments for each post
        //solution: give each post its own section
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count //we have as many sections as we have posts
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section] //the row stuff colects the particular post
        //also a problem
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        //what type of cell to return
        //post cell is always the 0th row
        if indexPath.row == 0 {

            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url)
            
            return cell
            
        } else if indexPath.row <= comments.count{
            //if there is 1 comment, then the 0th one is the post and 1 is the comment and 2 is the idecpath.row so if indexpath is 2?????
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        
            //now let's configure it
            let comment = comments[indexPath.row - 1] //because if indexpath is 0 the it is the postcell so then 1-1 =0 so 0th comment
            cell.commentLabel.text = comment["text"] as? String
            let user = comment["author"] as! PFUser //always need to cast it when coming out of dictionary
            cell.nameLabel.text = user.username
            
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
            //not dyaically modifying anything
        }
            
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]//row that I selected
        //comment object
        let comments = (post["comments"] as? [PFObject]) ?? []//will autocreate this columns
        
        //how do i know I am on last cell?
        if indexPath.row == comments.count + 1{
            showsCommentBar = true
            becomeFirstResponder() //if I call this aain it will call the reevaluation of value
            //to raise keyboard
            commentBar.inputTextView.becomeFirstResponder()//firstresponder is it will automaticlly show you he keyboard
            selectedPost = post //this is the one that U selected
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
