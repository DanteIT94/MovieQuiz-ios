//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Денис on 29.01.2023.
//

import UIKit
class QuestionFactory: QuestionFactoryProtocol {
    private let questions: [QuizQuestion] = [
        QuizQuestion(image: "The Godfather", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Dark Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Kill Bill", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Avengers", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Deadpool", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "The Green Knight", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: true),
        QuizQuestion(image: "Old", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "The Ice Age Adventures of Buck Wild", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Tesla", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false),
        QuizQuestion(image: "Vivarium", text: "Рейтинг этого фильма больше чем 6?", correctAnswer: false)
    ]
   private weak var delegate: QuestionFactoryDelegate?
    init(delegate: QuestionFactoryDelegate?) {
        self.delegate = delegate
    }
    func requestNextQuestion () { //Ничего не принимает, возвращает опц. модель QuizQuestion. Мы используем опционал на случай "Пустоты массива", чтобы приложение не "упало".(УЖЕ НЕАКТУАЛЬНО, делаем через Делегат)
        guard let index = (0..<questions.count).randomElement() else { //Выбираем индекс вопроса из массива Questions + Вопрос должен быть случайным (метод ".randomElement"). Так мы выбираем некоторое число в диапазоне от нуля до общего числа вопросов. У нас есть диапазон чисел, и мы применяем функцию randomElement. НО ЭТА ФУНКЦИЯ ВОЗВРАЩАЕТ ОПЦИОНАЛ, поэтому мы используем guard-let для расспаковки.
            //Почему мы используем "Полуоткрытый оператор"? так как ИНДЕКС ПОСЛЕДНЕГО ЭЛЕМЕНТА МАССИВА на 1 единицу меньше РАЗМЕРА МАССИВА, последний вопрос (в массиве из 10 вопросов) имеет индекс [9]. Мы просто исключаем последнее число.
            delegate?.didRecieveNextQuestion(question: nil)
            return
        }
        let question = questions[safe: index] //После того как мы получили случайный индекс - возьмем элемент из массива по этому индексу, но используем для этого "САБСКРИПТ". (Сабскрипт Extension-Array)
        delegate?.didRecieveNextQuestion(question: question)
    }
}
