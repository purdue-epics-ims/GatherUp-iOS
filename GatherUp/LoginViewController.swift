//
//  LoginViewController.swift
//  GatherUp
//
//  Created by Nikhil Nandkumar on 3/7/16.
//  Copyright © 2016 Nikhil Nandkumar. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    let database = Firebase(url: "https://dazzling-inferno-9963.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.usernameText.delegate = self
        self.passwordText.delegate = self
        
        self.usernameText.text = ""
        self.passwordText.text = ""
    }
    
    override func viewDidAppear(animated: Bool) {
        if NSUserDefaults.standardUserDefaults().valueForKey("accountUID") != nil {
            self.performSegueWithIdentifier("homePage", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onLoginPressed(sender: UIButton) {
        if let userId = usernameText.text where userId != "", let pwd = passwordText.text where pwd != "" {
            database.authUser(userId, password: pwd, withCompletionBlock: {
                error, authData in
                
                if error != nil {
                    if error.code == -8 {
                        self.showErrorAlert("Account does not exist", msg: "Oops! Looks like you haven't been authorized yet!")
                        
                    }
                    else {
                        self.showErrorAlert("Invalid UserID or Password", msg: "Oops! Looks like you've made a typo or forgotten your username/password!")
                    }
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "accountUID")
                    self.performSegueWithIdentifier("homePage", sender: nil)
                }
            })
        } else {
            showErrorAlert("User Email and Password Required", msg: "You must enter an e-mail ID and a password")
        }
    }
    
    @IBAction func onScreenTap(sender: UITapGestureRecognizer) {
        self.usernameText.resignFirstResponder()
        self.passwordText.resignFirstResponder()
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
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
