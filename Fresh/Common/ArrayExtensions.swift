//
//  ArrayExtensions.swift
//  Fresh
//
//  Created by Brandon Evans on 2016-01-08.
//  Copyright © 2016 Brandon Evans. All rights reserved.
//

extension Array {
    subscript(safe index: Int) -> Element? {
        if index < 0 || index >= count { return nil }
        return self[index]
    }
}
