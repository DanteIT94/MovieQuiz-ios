//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Денис on 01.03.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    
    //MARK: Properties
    private var questionFactory: QuestionFactoryProtocol?
    weak var viewController: MovieQuizViewController?
    private var currentQuestionIndex: Int = 0
    ///общее колличество вопросов квиза
    let questionsAmount: Int = 10
    var correctAnswers:Int = 0
    var currentQuestion: QuizQuestion?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
  // MARK: Methods
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        ///Если в замыканиях есть self, нужно использовать weak self. "Ослабленный" self является опционалом.
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionsOrResult () {
        if self.isLastQuestion() {
            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
            
            let viewModel = QuizResultsViewModel (
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть еще раз")
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
     }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
   func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
       viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
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
    
    func restartGame() {
        resetQustionIndex()
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
}
