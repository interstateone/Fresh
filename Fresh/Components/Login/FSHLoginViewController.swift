//
//  FSHLoginViewController.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-05.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

import Cocoa

class FSHLoginViewController: NSViewController {
    @IBAction func login(sender: AnyObject) {
        // TODO: Use presenter's service to log in
        SoundCloudService().logIn()
    }
}
