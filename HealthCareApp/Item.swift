//
//  Item.swift
//  HealthCareApp
//
//  Created by Yogesh Rathore on 25/06/25.
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
