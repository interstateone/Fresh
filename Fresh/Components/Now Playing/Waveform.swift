//
//  Waveform.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-05.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

final class Waveform: Decodable {
    var values = [Int]()

    init(json: JSON) throws {
        values = try json.get("samples")
    }

    static func decode(json: JSON) throws -> Self {
        return try self.init(json: json)
    }
}
