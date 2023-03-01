//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Денис on 24.02.2023.
//


import XCTest

final class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication! //эта переменная символизирует приложение, которое мы тестируем
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        // это специальная настройка для тестов: если один тест не прошёл, то следующие тесты запускаться не будут
        continueAfterFailure = false
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
//    func testYesButton() {
//        let indexLabel = app.staticTexts["Index"]
//        sleep(2)
//        let firstPoster = app.images["Poster"] //находим первоначальный постер
//        let firstPosterData = firstPoster.screenshot().pngRepresentation
//        app.buttons["Yes"].tap() //находим кнопку "Да" и нажимаем ее
//        sleep(2)
//        let secondPoster = app.images["Poster"]
//        let secondPosterData = secondPoster.screenshot().pngRepresentation
//        XCTAssertEqual(indexLabel.label, "2/10")
//        XCTAssertNotEqual(firstPosterData, secondPosterData) //Проверяем, что постеры разные
//    }
//    func testNoButton() {
//        let firstPoster = app.images["Poster"] //находим первоначальный постер
//                let firstPosterData = firstPoster.screenshot().pngRepresentation
//                app.buttons["No"].tap()
//        let secondPoster = app.images["Poster"]
//                let secondPosterData = secondPoster.screenshot().pngRepresentation
//                XCTAssertNotEqual(firstPosterData, secondPosterData) //Проверяем, что постеры разные
//    }
    func testAlertEnd() {
        sleep(1)
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        sleep(2)
        let finalAlert = app.alerts["Game results"]
        
        XCTAssertTrue(finalAlert.exists)
        XCTAssertTrue(finalAlert.label == "Этот раунд окончен!")
        XCTAssertTrue(finalAlert.buttons.firstMatch.label == "Сыграть еще раз")
        
    }
//    func testExample() throws {
//        // UI tests must launch the application that they test.
//        let app = XCUIApplication()
//        app.launch()
//
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
