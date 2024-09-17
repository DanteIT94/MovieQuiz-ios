//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Денис on 01.03.2023.
//

import UIKit


final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    //MARK: Properties
    private let statisticService: StatisticServices?
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticServicesImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
        
    }
    
    private var currentQuestionIndex: Int = 0
    ///общее колличество вопросов квиза
    private let questionsAmount: Int = 10
    private var correctAnswers:Int = 0
    ///переменная для хранения таймера
    private var timer: Timer?
    ///Переменная для хранения оставщегося времени
    var timeLeft: Int = 10
    private var currentQuestion: QuizQuestion?
    
    var resultMessage: String {
        guard let unwrappedStatisticService = statisticService else {
            return ""
        }
        unwrappedStatisticService.store(correct: correctAnswers, total: questionsAmount)
        let accurancyInPersent = String(format: "%.2f", (unwrappedStatisticService.totalAccurancy * 100)) + "%"
        let localilizedTime = unwrappedStatisticService.bestGame.date.dateTimeString
        let bestGameStatistic = "\(unwrappedStatisticService.bestGame.correct)/\(unwrappedStatisticService.bestGame.total)"
        
        let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)\n Колличество сыгранных квизов: \(unwrappedStatisticService.gamesCount)\n Рекорд: \(bestGameStatistic) (\(localilizedTime))\n Средняя точность: \(accurancyInPersent)"
        return text
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
    
    func proceedToNextQuestionOrResult () {
        if self.isLastQuestion() {
            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
            
            let viewModel = QuizResultsViewModel (
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            viewController?.show(quiz: viewModel)
            stopTimer()
        } else {
            stopTimer()
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            resetTimer()
            startTimer()
            viewController?.showLoadingIndicator()
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
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        } else {
            viewController?.wrongAnswer()
        }
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {return}
            self.proceedToNextQuestionOrResult()
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
        resetTimer()
        startTimer()
    }
    
    //MARK: Задаем функционал "Таймеру ответа"
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        timer?.invalidate()
        timeLeft = 10
        viewController?.updateButtonTitle(withTime: timeLeft)
    }
    
    @objc private func updateTimer() {
        if timeLeft > 0 {
            timeLeft -= 1
            viewController?.updateButtonTitle(withTime: timeLeft)
        } else {
            stopTimer()
            proceedWithAnswer(isCorrect: false)
        }
    }
    
}
