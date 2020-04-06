//
//  ScoreCalcTests.swift
//  QueendominoScoreAppTests
//
//  Created by Daniel Skalski on 05/04/2020.
//  Copyright © 2020 Daniel Skalski. All rights reserved.
//

import XCTest
@testable import QueendominoScore

class ScoreCalcTests: XCTestCase {

    var sut: ScoreCalculator!
    
    override func setUp() {
        super.setUp()
        sut = ScoreCalculator()
    }

    // MARK: test cases
    
    func testEmptyBoard() {
        let board = PlayerBoard()
        
        let result = sut.getScore(board)
        
        XCTAssertNotNil(result)
        XCTAssertTrue(result.domainScores.isEmpty)
    }
    
    func testSingleLineDomainBoard() {
        let board = createBoard([
            "f:2,f,f"
        ])
        
        let result = sut.getScore(board)
        
        XCTAssertTrue(result.domainScores[LandType.forrest]!.score == 6)
    }
    
    func testTwoSingleLineDomainsBoard() {
        let board = createBoard([
            "f:2,f,f",
            "c,c:1,c"
        ])
        
        let result = sut.getScore(board)
        
        XCTAssertTrue(result.domainScores[LandType.forrest]!.score == 6)
        XCTAssertTrue(result.domainScores[LandType.city]!.score == 3)
    }
    
    func testTwoLineDomainBoard() {
        let board = createBoard([
            "f,f,f",
            "f:2,f,f",
            "c,c:1,c"
        ])
        
        let result = sut.getScore(board)
        
        XCTAssertTrue(result.domainScores[LandType.forrest]!.score == 12)
        XCTAssertTrue(result.domainScores[LandType.city]!.score == 3)
    }
    
    func testSeparatedTwoLineDomainBoard() {
        let board = createBoard([
            "f,f,f,f,f",
            "f:1,f,c,f,f",
            "c,c:1,c,c,c"
        ])
        
        let result = sut.getScore(board)
        
        XCTAssertTrue(result.domainScores[LandType.forrest]!.score == 9)
        XCTAssertTrue(result.domainScores[LandType.city]!.score == 6)
    }
    
    func testTwoDifferentDomainsBoard() {
        let board = createBoard([
            "f,f,c,f,f:2",
            "f,f,c,f,f",
            "c,c,c,c,c:1"
        ])
        
        let result = sut.getScore(board)
        
        XCTAssertTrue(result.domainScores[LandType.forrest]!.score == 8)
        XCTAssertTrue(result.domainScores[LandType.city]!.score == 7)
    }
    
    func testTwoDifferentDomainsBothScoringBoard() {
        let board = createBoard([
            "f,f:1,c,f,f:2",
            "f,f,c,f,f",
            "c,c,c,c,c:1"
        ])
        
        let result = sut.getScore(board)
        
        XCTAssertTrue(result.domainScores[LandType.forrest]!.score == 12)
        XCTAssertTrue(result.domainScores[LandType.city]!.score == 7)
    }
    
    func testDomainWithoutCrownsScores0() {
        let board = createBoard([
            "f,f",
            "f,f",
        ])
        
        let result = sut.getScore(board)
        
        XCTAssertTrue(result.domainScores[LandType.forrest]!.score == 0)
    }

    // MARK: helper functions
    
    private func createBoard(_ boardStr: [String]) -> PlayerBoard {
        let board = PlayerBoard()
        
        for (x, rowStr) in boardStr.enumerated() {
            for (y, lp) in rowStr.split(separator: ",").enumerated() {
                let piece = createLandPiece(String(lp))
                board.put(piece, x: x, y: y)
            }
        }
        
        return board
    }
    
    private func createLandPiece(_ lp: String) -> LandPiece {
        let typeDesc = lp.first!
        var crownsCount = 0
        if lp.contains(":") {
            crownsCount = Int(String(lp.split(separator: ":").last!)) ?? 0
        }
        
        var landType: LandType
        switch typeDesc {
        case "f":
            landType = .forrest
        case "c":
            landType = .city
        case "g":
            landType = .grass
        case "p":
            landType = .plains
        case "d":
            landType = .dessert
        case "s":
            landType = .sea
        case "m":
            landType = .mine
        default:
            landType = .none
        }
        
        let landPiece = LandPiece(type: landType)
        landPiece.crownsCount = crownsCount
        return landPiece
    }
}
