//
//  PlayerScore.swift
//  QueendominoScoreApp
//
//  Created by Daniel Skalski on 04/04/2020.
//  Copyright © 2020 Daniel Skalski. All rights reserved.
//

import Foundation

class PlayerScore {
    var domainScores = [LandType : DomainScore]()
    
    func addScore(landType: LandType, score: Int) {
        if domainScores[landType] == nil {
            domainScores[landType] = DomainScore(type: landType)
        }
        domainScores[landType]!.score += score
    }
    
    struct DomainScore {
        let type: LandType
        var score: Int = 0
    }
}
