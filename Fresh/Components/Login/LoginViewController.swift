//
//  LoginViewController.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-05.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

import Cocoa
import WebKit

protocol LoginView {
    func closeLoginWindow()
}

class LoginViewController: NSViewController, LoginView {
    var presenter: LoginPresenter?
    var webView: WKWebView?
    var window: NSWindow?

    func closeLoginWindow() {
        window?.orderOut(self)
    }

    @IBAction func login(sender: AnyObject) {
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        window = NSWindow(contentRect: webView!.bounds, styleMask: NSTitledWindowMask | NSClosableWindowMask, backing: NSBackingStoreType.Buffered, `defer`: false)
        if let webView = webView, window = window {
            window.contentView = webView
            window.makeKeyAndOrderFront(self)
            presenter?.login(webView)
        }
    }
}
