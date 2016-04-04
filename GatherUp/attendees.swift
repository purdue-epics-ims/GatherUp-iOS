//
//  attendees.swift
//  GatherUp
//
//  Created by Nikhil Nandkumar on 2/6/16.
//  Copyright © 2016 Nikhil Nandkumar. All rights reserved.
//

import Foundation

class attendees {
    private var _puid:String?
    private var _lastName:String?
    private var _firstName:String?
    private var _email:String?
    
    var puid: String {
        if let exist = _puid where exist != "" {
            return _puid!
        }
        else {
            return ""
        }
    }
    
    var lastName: String {
        if let exist = _lastName where exist != "" {
            return _lastName!
        }
        else {
            return ""
        }
    }
    
    var firstName: String {
        if let exist = _firstName where exist != "" {
            return _firstName!
        }
        else {
            return ""
        }
    }
    
    var email: String {
        if let exist = _email where exist != "" {
            return _email!
        }
        else {
            return ""
        }
    }
    
    init(dict:Dictionary<String, AnyObject>) {
        if let puid = dict["puid"] as? String {
            self._puid = puid
        }
        if let lastName = dict["lastname"] as? String {
            self._lastName = lastName
        }
        if let firstName = dict["firstname"] as? String {
            self._firstName = firstName
        }
        if let email = dict["email"] as? String {
            self._email = email
        }
    }
    
    init(puid: String!, lastName: String!, firstName: String!, email: String!) {
        self._puid = puid
        self._lastName = lastName
        self._firstName = firstName
        self._email = email
    }
}