//
//  ScoreCalculator.swift
//  QueendominoScoreApp
//
//  Created by Daniel Skalski on 04/04/2020.
//  Copyright © 2020 Daniel Skalski. All rights reserved.
//

import Foundation

class ScoreCalculator {
    
    func getScore(_ board: PlayerBoard) -> PlayerScore {

        let foundDomains = findDomains(board)
        
        let playerScore = PlayerScore()
        for domain in foundDomains {
            let domainScore = domain.size * domain.crownsCount
            playerScore.addScore(landType: domain.type, score: domainScore)
        }
        
        return playerScore
    }
    
    private func findDomains(_ board: PlayerBoard) -> [LandDomain] {
        
        var foundDomains: [LandDomain] = []
        
        let noneLandDomain = LandDomain(type: LandType.none)
        var prevRowDomains: [LandDomain] = Array(repeating: noneLandDomain,
                                                 count: board.width)
        var currRowDomains: [LandDomain] = Array(repeating: noneLandDomain,
                                                 count: board.width)
        
        for y in 0..<board.height {
            var currDomain = prevRowDomains[0]
            for x in 0..<board.width {
                let currPiece = board.pieces[y][x]
                
                if currPiece.type == currDomain.type {
                    if currDomain.type == prevRowDomains[x].type
                        && currDomain !== prevRowDomains[x] {
                        // merge domains
                        let mergedDomain = prevRowDomains[x]
                        currDomain.size += mergedDomain.size
                        currDomain.crownsCount += mergedDomain.crownsCount
                        mergedDomain.mergedTo = currDomain
                    }
                } else if currPiece.type == prevRowDomains[x].type {
                    if prevRowDomains[x].mergedTo !== nil {
                        currDomain = prevRowDomains[x].mergedTo!
                    } else {
                        currDomain = prevRowDomains[x]
                    }
                } else {
                    currDomain = LandDomain(type: currPiece.type)
                    foundDomains.append(currDomain)
                }
                
                currDomain.size += 1
                currDomain.crownsCount += currPiece.crownsCount
                currRowDomains[x] = currDomain
            }
            prevRowDomains = currRowDomains
        }
        
        foundDomains = foundDomains.filter { $0.mergedTo == nil && $0.type != .none }
        
        return foundDomains
    }
    
    private class LandDomain {
        var size = 0
        var crownsCount = 0
        let type: LandType
        var mergedTo: LandDomain? = nil
        
        init(type: LandType) {
            self.type = type
        }
    }

}
