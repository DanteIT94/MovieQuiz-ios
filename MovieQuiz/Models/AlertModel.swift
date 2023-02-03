//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Денис on 03.02.2023.
//

import Foundation
import UIKit

struct AlertModel {
    let title: String //Текст заголовка Алерта
    let message: String //Текст сообщения Алерта
    let buttonText: String //текст для кнопки Алерта
    let completion: () -> () //замыкание без параметров для действия по кнопке аллерта
}
