//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Денис on 23.02.2023.
//
///ЭТО фреймформ для тестирования
import XCTest
///Базовый класс для всех unit-testов
//final class MovieQuizTests: XCTestCase {
//
//    ///Функция которая будет вызвана ПЕРЕД КАЖДЫМ тестом
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
/////Функция которая будет вызвана ПОСЛЕ КАЖДОГО теста
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    ///ЭТО САМ ТЕСТ. ТЕСТЫ - это функции внутри класса, которые начинаются с "test:"
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }
//
//    ///ЭТО НАГРУЗОЧНЫЙ ТЕСТ
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//}
//struct ArithmeticOperations {
//    func addition(num1: Int, num2: Int) -> Int {
//        return num1 + num2
//    }
//    func substraction(num1: Int, num2: Int) -> Int {
//        return num1 - num2
//    }
//    func multiplication(num1: Int, num2: Int) -> Int {
//        return num1 * num2
//    }
//}
///Ассинхронные тесты
struct ArithmeticOperations {
    func addition(num1: Int, num2: Int, handler: @escaping (Int) -> Void)  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            handler(num1 + num2)
        }
    }
    func substraction(num1: Int, num2: Int,  handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
        }
    }
    func multiplication(num1: Int, num2: Int, handler: @escaping (Int) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            handler(num1 * num2)
        }
    }
}

final class MovieQuizTests: XCTestCase {
    func testAddition() throws {
        //GIVEN
        let arithmeticOperations = ArithmeticOperations()
        let num1 = 1
        let num2 = 2
        //WHEN
        let expectation = expectation(description: "Addition function expectation")
        arithmeticOperations.addition(num1: num1 , num2: num2) {result in
            ///ПРИМИТИВ unit-тестов
            //THEN
            XCTAssertEqual(result, 3) //СРАВНИВАЕМ результат выполнения функции и наши ожидания
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)
        }
}
