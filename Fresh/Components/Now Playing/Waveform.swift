//
//  Waveform.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-05.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

class Waveform {
    var values = [Int]()

    init(json: JSON) throws {
        values = try json.get("samples")
    }
}
