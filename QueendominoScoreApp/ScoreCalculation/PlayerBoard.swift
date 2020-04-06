//
//  PlayerBoard.swift
//  QueendominoScoreApp
//
//  Created by Daniel Skalski on 24/03/2020.
//  Copyright © 2020 Daniel Skalski. All rights reserved.
//

import Foundation

class PlayerBoard {
    var pieces: [[LandPiece]]
    
    init() {
        pieces = Array(repeating: Array(repeating: LandPiece.None, count: 10),
                       count: 10)
    }
    
    func put(_ piece: LandPiece, x: Int, y: Int) {
        
        // TODO: adjust size of the board based on x and y
        // TODO: save min/max x/y for later compacting of the board
        
        pieces[x][y] = piece
    }
    
    var height: Int { return pieces.count }
    var width: Int { return pieces.first?.count ?? 0 }
    
//    func shrinkBoard() {
//        // This is bad - don't use it until it's fixed
//
//        pieces = pieces
//            .filter({ self.containsLandPiece($0) })
//            //.map({ self.compact($0) })
//    }
//
//    private func containsLandPiece(_ row: [LandPiece]) -> Bool {
//        return row.contains(where: {$0 !== LandPiece.None})
//    }
//
//    private func compact(_ row: [LandPiece]) -> [LandPiece] {
//
//        let lastNonePieceIndex =
//            row.lastIndex(where: { $0 !== LandPiece.None }) ?? row.count
//        let lastToDropCount = row.count - lastNonePieceIndex
//
//        let slice = row
//            .drop(while: { $0 === LandPiece.None })
//            .dropLast(lastToDropCount)
//
//        return Array(slice)
//    }
}
