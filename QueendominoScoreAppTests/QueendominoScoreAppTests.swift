//
//  QueendominoScoreAppTests.swift
//  QueendominoScoreAppTests
//
//  Created by Daniel Skalski on 24/03/2020.
//  Copyright © 2020 Daniel Skalski. All rights reserved.
//

import XCTest
@testable import QueendominoScore

class ScoreCalculatorTests: XCTestCase {

    var sut: ScoreCalculator!
    
    override func setUp() {
        super.setUp()
        sut = ScoreCalculator()
    }

    func testExample() {
        // given
        let board = PlayerBoard()
        
        // act
        let result = sut.getScore(board)
        
        // assert
        XCTAssertNotNil(result)
    }

}
