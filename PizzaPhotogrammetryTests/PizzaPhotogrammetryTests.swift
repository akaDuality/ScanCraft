//
//  PizzaPhotogrammetryTests.swift
//  PizzaPhotogrammetryTests
//
//  Created by Mikhail Rubanov on 11.06.2024.
//  Copyright © 2024 Apple. All rights reserved.
//

import XCTest
@testable import PizzaPhotogrammetry

final class MetricsTests: XCTestCase {

    @MainActor
    func test_whenAddNilMetrics_shouldCombine() throws {
        let sut = Processing(url: URL(string: "google.com")!)
        
        sut.stage = .creatingSession
        sut.stage = .preProcessing
        sut.stage = nil
        sut.stage = .preProcessing
        sut.stage = .imageAlignment
        
        XCTAssertEqual(sut.metrics.map(\.stage), [.creatingSession, .preProcessing, .imageAlignment])
    }
}
