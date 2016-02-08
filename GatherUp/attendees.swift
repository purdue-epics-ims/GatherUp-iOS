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
    
    init(name:String?, email:String?, puid:String?) {
        self._name = name
        self._email = email
        self._puid = puid
    }
}