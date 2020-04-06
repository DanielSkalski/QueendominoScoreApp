//
//  VisionToBoardConverter.swift
//  QueendominoScoreApp
//
//  Created by Daniel Skalski on 24/03/2020.
//  Copyright © 2020 Daniel Skalski. All rights reserved.
//

import Foundation
import Vision

class VisionToBoardConverter {
    
    func convert(_ observations: [VNRecognizedObjectObservation]) -> PlayerBoard {
        
        let landPiecesToVisit = observations
            .filter { $0.labels[0].identifier != "crown" }
            .map{ LandPieceToVisit(observation: $0) }
        
        let crownObservations = observations
            .filter { $0.labels[0].identifier == "crown" }
        
        for piece in landPiecesToVisit {
            let otherPieces = landPiecesToVisit.filter { $0 !== piece }
            connectNeighbors(piece, otherPieces)
            connectCrowns(piece, crowns: crownObservations)
        }
        
        let board = self.constructBoard(landPiecesToVisit)

        return board
    }
    
    // MARK: Construct board
    
    private func constructBoard(_ pieces: [LandPieceToVisit]) -> PlayerBoard {
        let board = PlayerBoard()
        
        if pieces.count == 0 {
            return board
        }
        
        placeOnBoard(pieces.first!, board, posX: 5, posY: 5)
        
        // TODO: make sure we've put every piece on board
        
        return board
    }
    
    private func placeOnBoard(_ piece: LandPieceToVisit, _ board: PlayerBoard,
                              posX: Int, posY: Int) {
        
        if piece.wasPlacedOnBoard {
            return
        }
        
        board.put(piece.landPiece, x: posX, y: posY)
        piece.wasPlacedOnBoard = true
        
        if piece.connectedPieces[.north] != nil {
            placeOnBoard(piece.connectedPieces[.north]!, board,
                         posX: posX,
                         posY: posY - 1)
        }
        if piece.connectedPieces[.south] != nil {
            placeOnBoard(piece.connectedPieces[.south]!, board,
                         posX: posX,
                         posY: posY + 1)
        }
        if piece.connectedPieces[.west] != nil {
            placeOnBoard(piece.connectedPieces[.west]!, board,
                         posX: posX - 1,
                         posY: posY)
        }
        if piece.connectedPieces[.east] != nil {
            placeOnBoard(piece.connectedPieces[.east]!, board,
                         posX: posX + 1,
                         posY: posY)
        }
    }
    
    // MARK: Connect pieces
    
    private func connectNeighbors(_ piece: LandPieceToVisit,
                                  _ otherPieces: [LandPieceToVisit]) {
        
        for direction in Direction.allCases {
            connectOnDirection(piece, otherPieces, direction)
        }

    }
    
    private func connectOnDirection(_ piece: LandPieceToVisit,
                                    _ otherPieces: [LandPieceToVisit],
                                    _ direction: Direction) {
        
        if piece.connectedPieces[direction] !== nil {
            return
        }
        
        let checkRect = createCheckRect(piece, direction)
        let foundConnection = otherPieces.first {
            checkRect.contains($0.centerPoint)
        }
        
        if foundConnection !== nil {
            let oppositeDirection = Direction.init(rawValue: -direction.rawValue)!
            piece.connectedPieces[direction] = foundConnection!
            foundConnection!.connectedPieces[oppositeDirection] = piece
        }
    }
    
    private func createCheckRect(_ piece: LandPieceToVisit, _ direction: Direction) -> CGRect {
        let insetDx = piece.boundingBox.width / 3.0
        let insetDy = piece.boundingBox.height / 3.0
        
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0
        
        switch direction {
        case .north:
            offsetX = -piece.boundingBox.width
        case .south:
            offsetX = piece.boundingBox.width
        case .west:
            offsetY = -piece.boundingBox.height
        case .east:
            offsetY = piece.boundingBox.height
        }
        
        let checkRect = piece.boundingBox
            .insetBy(dx: insetDx, dy: insetDy)
            .offsetBy(dx: offsetX, dy: offsetY)

        return checkRect
    }
    
    private func connectCrowns(_ piece: LandPieceToVisit,
                               crowns: [VNRecognizedObjectObservation]) {
        
        let crownsOnPieceCount = crowns
            .filter { piece.boundingBox.contains($0.boundingBox) }
            .count
        
        piece.setCrownsCount(crownsOnPieceCount)
    }
    
    private enum Direction : Int, CaseIterable {
        case north = 1, south = -1, west = 2, east = -2
    }

    private class LandPieceToVisit {
        
        private let observation: VNRecognizedObjectObservation
        let landPiece: LandPiece
        var wasPlacedOnBoard: Bool = false
        
        var connectedPieces: [Direction : LandPieceToVisit] = [:]
        
        var boundingBox: CGRect { return observation.boundingBox }
        var centerPoint: CGPoint { return CGPoint(x: boundingBox.midX,
                                                  y: boundingBox.midY) }
        
        init(observation: VNRecognizedObjectObservation) {
            self.observation = observation
            self.landPiece = LandPiece(
                typeStr: observation.labels[0].identifier)
        }
        
        func setCrownsCount(_ count: Int) {
            landPiece.crownsCount = count
        }

    }
    
}
