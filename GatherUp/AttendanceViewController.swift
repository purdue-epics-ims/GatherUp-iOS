//
//  AttendanceViewController.swift
//  GatherUp
//
//  Created by Nikhil Nandkumar on 2/23/16.
//  Copyright © 2016 Nikhil Nandkumar. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import AudioToolbox
import MediaPlayer
import Firebase
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class AttendanceViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var successText: UILabel!
    
    
    fileprivate var uniMagObject: uniMag!
    
    var uniMagViewController: UniMagViewController = UniMagViewController()
    
    var eventAttendees = [attendees]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.showAlert("Swiper Connected", msg: "You may begin swiping Purdue IDs")
        
        // Do any additional setup after loading the view.
        
        //self.title = NSUserDefaults.standardUserDefaults().valueForKey("selectedEventName") as! String
        
        NotificationCenter.default.addObserver(self, selector: #selector(AttendanceViewController.uniMagConnected(_:)), name: NSNotification.Name(rawValue: uniMagDidConnectNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AttendanceViewController.swipeReceived(_:)), name: NSNotification.Name(rawValue: uniMagDidReceiveDataNotification), object: nil)
        
        uniMagViewController.umsdk_activate()
        uniMagViewController.connectReader()
        
        uniMag.enableLogging(true)
        self.uniMagObject = uniMag()
        
        uniMagObject.setAutoConnect(false)
        
        uniMagObject.setSwipeTimeoutDuration(0)
        
        uniMagObject.setAutoAdjustVolume(true)
        
        self.firstNameText.delegate = self
        self.lastNameText.delegate = self
        self.emailText.delegate = self
        
        let selectedEvent = UserDefaults.standard.value(forKey: "selectedEvent") as! String
        
        let database = Firebase(url: "https://dazzling-inferno-9963.firebaseio.com/event/"+selectedEvent+"/attendees")
        
        database?.observe(.value, with: { snapshot in
            if let snapshots = snapshot?.children.allObjects as? [FDataSnapshot] {
                self.eventAttendees = []
                for snap in snapshots {
                    if let attendeesDict = snap.value as? Dictionary<String, AnyObject> {
                        let attendee = attendees(dict: attendeesDict)
                        self.eventAttendees.append(attendee)
                    }
                }
            }
        })
        
        self.navigationItem.hidesBackButton = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(AttendanceViewController.goToList(_:)))
        
        self.checkmarkImage.isHidden = true
        self.successText.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPressRegister(_ sender: UIButton!) {
        if let fName = firstNameText.text , fName != "", let lName = lastNameText.text , lName != "", let email = emailText.text , email != "" {
            
            var exists = 0;
            var emailValidityChecksPassed = 0;
            
            for attendee in eventAttendees {
                if (lName == attendee.lastName && fName == attendee.firstName && email == attendee.email) {
                    
                    UIView.animate(withDuration: 1.0, animations: {
                        self.view.backgroundColor = UIColor.yellow
                    })
                    
                    UIView.animate(withDuration: 1.0, animations: {
                        self.view.backgroundColor = UIColor.white
                    })
                    
                    exists = 1
                }
            }
            
            for character in email.characters {
                if character == "@" {
                    emailValidityChecksPassed += 1
                }
                if (emailValidityChecksPassed == 1 && character == ".") {
                    emailValidityChecksPassed += 1;
                } else if(emailValidityChecksPassed == 2) {
                    emailValidityChecksPassed += 1;
                }
            }
            
            if (exists == 0 && emailValidityChecksPassed == 3) {
                self.showAlert("Registered!", msg: "You have successfully registered for the event!")
                postToFirebase(lastName: lName, firstName: fName, email: email)
                
                firstNameText.text = ""
                lastNameText.text = ""
                emailText.text = ""
            }
            
            else if emailValidityChecksPassed != 3 {
                self.showAlert("Invalid Email", msg: "Please enter a valid email address!")
            }
            /*
            else {
                self.showAlert("Unsuccessful", msg: "You have already registered for the event!")
            }*/
            
        } else {
            self.showAlert("Required Text Fields Empty", msg: "Please fill in your first name, last name and email ID to register")
        }
    }
    
    @IBAction func onScreenTap(_ sender: UITapGestureRecognizer!) {
        self.firstNameText.resignFirstResponder()
        self.lastNameText.resignFirstResponder()
        self.emailText.resignFirstResponder()
    }
    
    func uniMagConnected(_ notification: Notification) {
        self.showAlert("Swiper Connected", msg: "You may begin swiping Purdue IDs")
        uniMagViewController.swipeCard()
    }
    
    func swipeReceived(_ notification: Notification!) {
        let rawData = notification.object as! Data
        // parse and do stuff with the swipe information
        print(rawData)
        var parsedData = String(data: rawData, encoding: String.Encoding.utf8)! // Try "\(rawData)"
        print("Parsed Data: ", parsedData)
        //Parsed Data = ;000000000=2229=0028437472=02?
        
        //Get valid PUID digits
        
        var range = parsedData.startIndex..<parsedData.characters.index(parsedData.startIndex, offsetBy: 16)
        parsedData.removeSubrange(range)
        
        range = parsedData.characters.index(parsedData.startIndex, offsetBy: 10)..<parsedData.endIndex
        parsedData.removeSubrange(range)
        
        var checker = Int(parsedData)
        
        var luhn:Int = 0
        
        for tempChar in parsedData.unicodeScalars {
            if (tempChar.value < 48 || tempChar.value > 57) {
                luhn = 1
            }
        }
        
        var factor:Int = 1
        
        while checker > 0 {
            var addendum:Int = (checker! % 10) * factor
            
            if addendum >= 10 {
                var modifiedAddendum:Int = 0
                
                while addendum > 0 {
                    modifiedAddendum = modifiedAddendum + addendum % 10
                    addendum = Int(addendum / 10)
                }
                
                addendum = modifiedAddendum
            }
            
            luhn = luhn + addendum
            
            factor = factor + 1
            checker = Int(checker! / 10)
        }
        
        luhn = luhn % 10
        
        if luhn == 0 {
            
            var exists = 0;
            
            for attendee in eventAttendees {
                if parsedData == attendee.puid {
                    
                    UIView.animate(withDuration: 1.0, animations: {
                        self.view.backgroundColor = UIColor.yellow
                    })
                    
                    UIView.animate(withDuration: 1.0, animations: {
                        self.view.backgroundColor = UIColor.white
                    })
                    
                    exists = 1
                }
            }
            
            if exists == 0 {
            
                UIView.animate(withDuration: 1.0, animations: {
                    self.view.backgroundColor = UIColor.green
                })
                
                Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(AttendanceViewController.showSuccess), userInfo: nil, repeats: false)
                
                Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(AttendanceViewController.hideSuccess), userInfo: nil, repeats: false)
                
                UIView.animate(withDuration: 1.0, animations: {
                    self.view.backgroundColor = UIColor.white
                })
                
                print("Card Data: \(parsedData)")
                
                postToFirebase(puid: parsedData)
                    
            }
            
        }
        
        else {
            
            UIView.animate(withDuration: 1.0, animations: {
                self.view.backgroundColor = UIColor.red
            })
            
            UIView.animate(withDuration: 1.0, animations: {
                self.view.backgroundColor = UIColor.white
            })
        }
        
        uniMagViewController.swipeCard()
    }
    
    func showAlert(_ title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func postToFirebase(puid: String = "", lastName: String = "", firstName:String = "", email: String = "") {
        let newAttendee: Dictionary<String,AnyObject> = [
            "puid": puid as AnyObject,
            "lastname": lastName as AnyObject,
            "firstname": firstName as AnyObject,
            "email": email as AnyObject
        ]
        
        let selectedEvent = UserDefaults.standard.value(forKey: "selectedEvent") as! String
        
        let database = Firebase(url: "https://dazzling-inferno-9963.firebaseio.com/event/"+selectedEvent+"/attendees")
        
        database?.childByAutoId().setValue(newAttendee)
    }
    
    func goToList(_ sender: UIBarButtonItem){
        self.navigationController?.popViewController(animated: true)
    }
    
    func showSuccess(){
        self.checkmarkImage.isHidden = false
        self.successText.isHidden = false
    }
    
    func hideSuccess(){
        self.checkmarkImage.isHidden = true
        self.successText.isHidden = true
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
