//
//  LoginPresenter.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-12.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Cocoa
import WebKit

class LoginPresenter {
    let view: LoginView
    let configuration: OAuthConfiguration
    let completion: (OAuthAuthentication) -> Void
    var authService: AuthenticatorService?
    
    init(view: LoginView, configuration: OAuthConfiguration, completion: (OAuthAuthentication) -> Void) {
        self.view = view
        self.configuration = configuration
        self.completion = completion
    }
    
    func login(webView: WKWebView) {
        let browserService = BrowserService(configuration: configuration, webView: webView)
        self.authService = AuthenticatorService(configuration: configuration, service: browserService)
        let request = SoundCloudEndpoint.Connect.request
        authService!.request(request).start({ [weak self] event in
            guard let _self = self else { return }
            if let data = event.value?.1, json = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as? [String: String] {
                do {
                    let auth = try OAuthAuthentication.decode(JSON(json))
                    _self.completion(auth)
                    NSLog("%@", "\(json)")
                    _self.view.closeLoginWindow()
                }
                catch {}
            }
        })
    }
}