//
//  TokenService.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-13.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

import Foundation
import ReactiveCocoa

class TokenService: CompositeService {
    let authentication: OAuthAuthentication
    let service: Service

    init(authentication: OAuthAuthentication, service: Service) {
        self.authentication = authentication
        self.service = service
    }

    var parameters: [String: String] {
        return [ "oauth_token": authentication.accessToken ]
    }

    var queryItems: [NSURLQueryItem] {
        var items: [NSURLQueryItem] = []
        for (key, value) in parameters {
            items.append(NSURLQueryItem(name: key, value: value))
        }
        return items
    }

    func addToken(request: NSURLRequest) -> NSURLRequest {
        if let URL = request.URL, URLComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false) {
            let items = URLComponents.queryItems ?? []
            URLComponents.queryItems = items + queryItems
            if let newURL = URLComponents.URL {
                return NSURLRequest(URL: newURL)
            }
        }
        return request
    }

    func request(request: NSURLRequest) -> SignalProducer<(NSURLResponse?, NSData), NSError> {
        return self.service.request(self.addToken(request))
    }
}