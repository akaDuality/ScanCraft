//
//  PizzaPhotogrammetryTests.swift
//  PizzaPhotogrammetryTests
//
//  Created by Mikhail Rubanov on 11.06.2024.
//  Copyright © 2024 Apple. All rights reserved.
//

import XCTest
@testable import PizzaPhotogrammetry

final class PizzaPhotogrammetryTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        let sut = Processing(url: URL(string: "google.com")!)
        
        sut.stage = .creatingSession
        sut.stage = .preProcessing
        sut.stage = nil
        sut.stage = .preProcessing
        sut.stage = .imageAlignment
        
        XCTAssertEqual(sut.metrics.map(\.stage), [.creatingSession, .preProcessing, .imageAlignment])
    }

}
