//
//  Item.swift
//  Blog
//
//  Created by Tyler Grissom on 12/25/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
