//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Денис on 14.02.2023.
//

import UIKit
protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

///Загрузка данных из URL
struct NetworkClient: NetworkRouting {
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url) //создаем запрос в url
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            /// Проверка на ошибку
            if let error = error {
                handler(.failure(error))
                return
            }
            /// Проверка на успешность получения кода ответа
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            ///Возвращение данных
            guard let data = data else {return}
            handler(.success(data))
        }
        task.resume()
    }
}
