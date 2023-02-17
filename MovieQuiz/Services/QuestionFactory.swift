//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Денис on 29.01.2023.
//

import UIKit
class QuestionFactory: QuestionFactoryProtocol {
    
    private var movies: [MostPopularMovie] = []
    private let moviesLoader: MoviesLoading
   private weak var delegate: QuestionFactoryDelegate?
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies {[weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items // сохраняем фильм в переменную
                    self.delegate?.didLoadDataFromServer() //Проверка, загрузились ли данные
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)//Сообщаем об ошибке нащему MovieQuizController
                }
            }
        }
    }
    
    func requestNextQuestion () {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            //Выбираем индекс вопроса из массива movies + Вопрос должен быть случайным (метод ".randomElement")
            //Почему мы используем "Полуоткрытый оператор"? так как ИНДЕКС ПОСЛЕДНЕГО ЭЛЕМЕНТА МАССИВА на 1 единицу меньше РАЗМЕРА МАССИВА, последний вопрос (в массиве из 10 вопросов) имеет индекс [9]. Мы просто исключаем последнее число.
            guard let movie = self.movies[safe: index] else { return } //После того как мы получили случайный индекс - возьмем элемент из массива по этому индексу, но используем для этого "САБСКРИПТ". (Сабскрипт Extension-Array)
            var imageData = Data()//по дефолту - пустые данные
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let movieText = [
            "Рейтинг этого фильма больше, чем 9?",
            "Рейтинг этого фильма меньше или равен 9?"]
            let randomIndex = Int.random(in: 0..<movieText.count)
            let text = movieText[randomIndex]
            
            let correctAnswer: Bool
            switch text {
            case "Рейтинг этого фильма больше, чем 9?":
                correctAnswer = rating > 9
            case "Рейтинг этого фильма меньше или равен 9?":
                correctAnswer = rating <= 9
            default:
                fatalError("unexpected movie text: \(text)")
            }
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {return}
                self.delegate?.didRecieveNextQuestion(question: question)
            }
        }
    }
}
