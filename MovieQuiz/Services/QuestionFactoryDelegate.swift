//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Денис on 01.02.2023.
//

import UIKit
///Создаем протокол, который будем использовать в фабрике как "Делегата". Используем AnyObject, чтобы ограничить наш протокол КЛАССАМИ - в дальнейшем это пригодиться при создании слабых ссылок.
protocol QuestionFactoryDelegate: AnyObject {
    ///объявляем метод, который должен быть у делегата фабрики
    func didRecieveNextQuestion(question: QuizQuestion?)
    ///Сообщение об успешной загрузке
    func didLoadDataFromServer()
    ///Сообщение об ошибке
    func didFailToLoadData(with error: Error)
}
