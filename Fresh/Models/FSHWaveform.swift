//
//  FSHWaveform.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-08-05.
//  Copyright (c) 2015 Brandon Evans. All rights reserved.
//

import Foundation

class FSHWaveform: MTLModel, MTLJSONSerializing {
    var values = [Int]()

    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }

    required init!(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
        super.init(dictionary: dictionaryValue, error: error)
    }

    override init() { super.init() }

    var max: Int {
        return self.values.reduce(0) { (memo, value) -> Int in
            if value > memo { return value }
            return memo
        }
    }

    // MARK: MTLJSONSerializing

    class func JSONKeyPathsByPropertyKey() -> [NSObject : AnyObject]! {
        return [
            "values": "samples"
        ]
    }
}
