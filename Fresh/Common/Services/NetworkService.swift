//
//  NetworkService.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-13.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Alamofire

public protocol Endpoint {
    var path: NSURL { get }
    var parameters: [NSURLQueryItem] { get }
    // I couldn't figure out how to make a failable convenience initializer for NSURLRequest for some reason, so doing this instead
    var request: NSURLRequest { get }
}

public enum SoundCloudEndpoint: Endpoint {
    case Connect
    case Popular(Int, Int) // limit, offset
    case Me
    case Activities
    case Favorites(favorite: Bool, trackID: Int)

    var baseURL: NSURL {
        switch self {
        case Connect: return NSURL(string: "https://soundcloud.com")!
        case Popular: return NSURL(string: "https://api-v2.soundcloud.com")!
        default: return NSURL(string: "https://api.soundcloud.com")!
        }
    }

    // TODO use method in request
    public var method: Alamofire.Method {
        switch self {
        case Favorites(let favorite, _): return favorite ? .PUT : .DELETE
        default: return .GET
        }
    }

    public var path: NSURL {
        let path: String
        switch self {
        case Connect: path = "connect"
        case Popular: path = "explore/popular music"
        case Me: path = "me"
        case Activities: path = "me/activities"
        case Favorites(let trackID): path = "me/favorites/\(trackID)"
        }
        return baseURL.URLByAppendingPathComponent(path)
    }

    public var parameters: [NSURLQueryItem] {
        switch self {
        case let Popular(limit, offset): return [
            NSURLQueryItem(name: "limit", value: String(limit)),
            NSURLQueryItem(name: "offset", value: String(offset))
        ]
        default: return []
        }
    }

    public var request: NSURLRequest {
        let URLComponents = NSURLComponents(URL: path, resolvingAgainstBaseURL: false)!
        URLComponents.queryItems = parameters
        let URL = URLComponents.URL!
        return NSURLRequest(URL: URL)
    }
}

public struct OAuthConfiguration {
    let appID: String
    let appSecret: String
    let redirectURL: NSURL
}

public struct OAuthAuthentication: Decodable, CustomStringConvertible {
    let accessToken: String
    let scope: String

    static func decode(json: JSON) throws -> OAuthAuthentication {
        return OAuthAuthentication(
            accessToken: try json.get("access_token"),
            scope: try json.get("scope")
        )
    }

    public var description: String {
        return "accessToken: \(accessToken)\nscope: \(scope)"
    }
}

public enum OAuthState {
    case Unauthenticated(OAuthConfiguration)
    case Authenticated(OAuthConfiguration, OAuthAuthentication)
}

protocol Service {
    func request(request: NSURLRequest) -> SignalProducer<(NSURLResponse?, NSData), NSError>
}

protocol CompositeService: Service {
    var service: Service { get }
}

public class NetworkService: Service {
    let session: NSURLSession

    public init(session: NSURLSession) {
        self.session = session
    }

    func request(request: NSURLRequest) -> SignalProducer<(NSURLResponse?, NSData), NSError> {
        return SignalProducer { observer, disposable in
            self.session.dataTaskWithRequest(request) { data, response, error in
                if let error = error {
                    observer.sendFailed(error)
                }
                else {
                    observer.sendNext(response, data!)
                    observer.sendCompleted()
                }
            }.resume()
        }
    }
}