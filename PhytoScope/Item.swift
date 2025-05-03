//
//  Item.swift
//  PhytoScope
//
//  Created by Daniil Shmoylov on 03.05.2025.
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
