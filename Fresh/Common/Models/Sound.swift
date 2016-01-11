//
//  Sound.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-10.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

import Foundation

// The only reason that any non-optional properties are vars with default values is because you can't throw in an initializer until all properties are stored. When this changes the properties should be reverted.
final class Sound: CustomStringConvertible, Equatable, Decodable {
    var trackID: Int = 0
    var title: String = ""
    var author: String = ""
    var streamURL: NSURL? = nil
    var playURL: NSURL? = nil
    var streamable: Bool = false
    var duration: Double = 0
    var createdAt: NSDate = NSDate()
    var artworkURL: NSURL? = NSURL()
    var waveformURL: NSURL? = nil
    var permalinkURL: NSURL = NSURL()
    var favorite: Bool = false
    
    init(json: JSON) throws {
        trackID = try json.get("origin", "id")
        title = try json.get("origin", "title")
        author = try json.get("origin", "user", "username")
        streamURL = try? json.get("origin", "stream_url")
        streamable = try json.get("origin", "streamable")
        duration = try json.get("origin", "duration")
        artworkURL = try? json.get("origin", "artwork_url")
        waveformURL = try? json.get("origin", "waveform_url")
        permalinkURL = try json.get("origin", "permalink_url")
        favorite = try json.get("origin", "user_favorite")
        createdAt = try json.getJSON("created_at").decode { json in
            guard let JSONString = json.object as? String else {
                throw DecodingError.TypeMismatch(expected: String.self, actual: json.object.dynamicType)
            }
            guard let date = Sound.dateFormatter.dateFromString(JSONString) else {
                throw DecodingError.Undecodable(explanation: "Unable to create a NSDate from the string \"\(JSONString)\"")
            }
            return date
        }
    }

    static func decode(json: JSON) throws -> Self {
        return try self.init(json: json)
    }

    private static let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss Z"
        return dateFormatter
    }()

    // MARK: CustomStringConvertible

    var description: String {
        return "Sound \(trackID): \(title) by \(author)"
    }
}

func ==(lhs: Sound, rhs: Sound) -> Bool {
    return lhs.trackID == rhs.trackID
}
