//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Денис on 01.02.2023.
//

import UIKit
protocol QuestionFactoryDelegate: AnyObject { //Создаем протокол, который будем использовать в фабрике как "Делегата". Используем AnyObject, чтобы ограничить наш протокол КЛАССАМИ - в дальнейшем это пригодиться при создании слабых ссылок.
    func didRecieveNextQuestion(question: QuizQuestion?) //объявляем метод, который должен быть у делегата фабрики
    func didLoadDataFromServer() //Сообщение об успешной загрузке
    func didFailToLoadData(with error: Error)//Сообщение об 
}
