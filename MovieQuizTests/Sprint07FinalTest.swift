//
//  Sprint07FinalTest.swift
//  MovieQuizTests
//
//  Created by Денис on 03.03.2023.
//

import Foundation
import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func wrongAnswer() {
    }
    
    func show(quiz step: QuizStepViewModel) {
    }
    
    func show(quiz result: QuizResultsViewModel) {
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
    }
    
    func showLoadingIndicator() {
    }
    
    func hideLoadingIndicator() {
    }
    
    func showNetworkError(message: String) {
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
