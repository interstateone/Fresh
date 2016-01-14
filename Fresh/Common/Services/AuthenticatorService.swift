//
//  AuthenticatorService.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-14.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

import Foundation
import ReactiveCocoa

class AuthenticatorService: CompositeService {
    let configuration: OAuthConfiguration
    let service: Service
    
    init(configuration: OAuthConfiguration, service: Service) {
        self.configuration = configuration
        self.service = service
    }
    
    private var parameters: [NSURLQueryItem] {
        return [
            NSURLQueryItem(name: "client_id", value: configuration.appID),
            NSURLQueryItem(name: "client_secret", value: configuration.appSecret),
            NSURLQueryItem(name: "response_type", value: "token"),
            NSURLQueryItem(name: "redirect_uri", value: configuration.redirectURL.absoluteString ?? ""),
            NSURLQueryItem(name: "display", value: "popup")
        ]
    }

    private func prepareRequest(request: NSURLRequest) -> NSURLRequest {
        if let URL = request.URL, URLComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false) {
            URLComponents.queryItems = parameters
            if let mutableRequest = request.mutableCopy() as? NSMutableURLRequest {
                mutableRequest.URL = URLComponents.URL
                return mutableRequest
            }
        }
        return request
    }
    private func jsonFromQueryItems(queryItems: [NSURLQueryItem]) -> [String: String] {
        var JSON: [String: String] = [:]
        for queryItem in queryItems {
            if let value = queryItem.value {
                JSON[queryItem.name] = value
            }
        }
        return JSON
    }

    // For some reason the redirect URL is of the form scheme://path?#queryItems where the queryItems are actually in the place of a URL fragment and don't get parsed correctly by NSURLComponents so we have to do it manually.
    private func queryItemsFromURL(URL: NSURL) -> [NSURLQueryItem]? {
        if let fragment = URL.fragment {
            return fragment.componentsSeparatedByString("&").reduce([NSURLQueryItem]()) { (var accumulator, queryItemString) in
                let components = queryItemString.componentsSeparatedByString("=")
                if let name = components.first where components.count > 1 {
                    let value = components[1]
                    accumulator.append(NSURLQueryItem(name: name, value: value))
                }
                return accumulator
            }
        }
        return nil
    }

    private func isRedirectToApp(URL: NSURL) -> Bool {
        return configuration.redirectURL.scheme == URL.scheme
    }
    
    func request(request: NSURLRequest) -> SignalProducer<(NSURLResponse?, NSData), NSError> {
        let modifiedRequest = prepareRequest(request)
        return service.request(modifiedRequest)
            .filter { result in
                if let string = NSString(data: result.1, encoding: NSUTF8StringEncoding) as? String,
                    URL = NSURL(string: string) {
                        return self.isRedirectToApp(URL)
                }
                return false
            }
            .take(1)
            .map { result in
                if let string = NSString(data: result.1, encoding: NSUTF8StringEncoding) as? String,
                    URL = NSURL(string: string),
                    queryItems = self.queryItemsFromURL(URL),
                    data = try? NSJSONSerialization.dataWithJSONObject(self.jsonFromQueryItems(queryItems), options: NSJSONWritingOptions()) {
                        return (result.0, data)
                }
                return result
        }
    }
}