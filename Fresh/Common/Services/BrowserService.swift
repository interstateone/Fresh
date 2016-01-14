//
//  BrowserService.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-13.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

import Foundation
import ReactiveCocoa
import WebKit

public class BrowserService: NSObject, Service, WKNavigationDelegate {
    let configuration: OAuthConfiguration
    let webView: WKWebView
    var observer: Observer<(NSURLResponse?, NSData), NSError>?

    init(configuration: OAuthConfiguration, webView: WKWebView) {
        self.configuration = configuration
        self.webView = webView
        super.init()
        self.webView.navigationDelegate = self
    }

    func request(request: NSURLRequest) -> SignalProducer<(NSURLResponse?, NSData), NSError> {
        return SignalProducer { [weak self] observer, disposal in
            if let _self = self {
                _self.observer = observer
                _self.webView.loadRequest(request)
            }
        }
    }

    // MARK: WKNavigationDelegate

    public func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let URL = navigationAction.request.URL,
            data = URL.absoluteString.dataUsingEncoding(NSUTF8StringEncoding),
            observer = observer {
            observer.sendNext((nil, data))
        }
        decisionHandler(WKNavigationActionPolicy.Allow)
    }

    // TODO: Failure modes with other delegate methods
}