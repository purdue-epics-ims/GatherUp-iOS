//
//  attendees.swift
//  GatherUp
//
//  Created by Nikhil Nandkumar on 2/6/16.
//  Copyright © 2016 Nikhil Nandkumar. All rights reserved.
//

import Foundation

class attendees {
    private var _name:String?
    private var _email:String?
    private var _puid:String?
    
    var name: String {
        if let exist = _name where exist != "" {
            return _name!
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
    
    var puid: String {
        if let exist = _puid where exist != "" {
            return _puid!
        }
        else {
            return ""
        }
    }
    
    init(name:String!, email:String!) {
        self._name = name
        self._email = email
    }
    
    init(puid:String!) {
        self._puid = puid
    }
}