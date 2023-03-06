//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by Денис on 23.02.2023.
//

import Foundation
import XCTest //Импортируем фреймворк для тестирования
@testable import MovieQuiz //Испортируем само приложение для тестов

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {//тест на успешное взятие элемента по индексу
        ///Given
        let array = [1,1,2,3,5]
        ///When
        let value = array[safe: 2]
        ///Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    func testGetValueOutOfRange() throws {
        ///Given
        let array = [1,1,2,3,5]
        ///When
        let value = array[safe: 20]
        ///Then
        XCTAssertNil(value)
    }
}


