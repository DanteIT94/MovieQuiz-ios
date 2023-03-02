//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Денис on 01.03.2023.
//

import UIKit

final class MovieQuizPresenter {
    
    private var currentQuestionIndex: Int = 0
    ///общее колличество вопросов квиза
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
  // MARK: methods
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
   func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
       viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQustionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
}
