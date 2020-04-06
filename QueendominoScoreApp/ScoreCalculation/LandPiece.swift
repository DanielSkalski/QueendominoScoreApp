//
//  LandPiece.swift
//  QueendominoScoreApp
//
//  Created by Daniel Skalski on 24/03/2020.
//  Copyright © 2020 Daniel Skalski. All rights reserved.
//

import Foundation

class LandPiece {
    var type: LandType = LandType.none
    var crownsCount: Int = 0
    
    init(typeStr: String) {
        type = LandType(rawValue: typeStr)!
    }
    
    init(type: LandType) {
        self.type = type
    }
    
    static var None: LandPiece  = LandPiece(type: .none)
}

enum LandType : String {
    case grass, plains, city, dessert, sea, forrest, mine, none
}
