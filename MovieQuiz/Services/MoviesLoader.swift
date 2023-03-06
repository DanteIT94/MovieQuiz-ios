//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Денис on 14.02.2023.
//

import UIKit

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    //MARK: - NetworkClient
    private let networkClient: NetworkRouting
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    //MARK: - URL
    var mostPopularMoviesUrl: URL {
        // Если не преобразуем строку в URL, приложение вылетает с ошибкой
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_2ll00pp0") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) {result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    
}
