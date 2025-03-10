//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Денис on 14.02.2023.
//

import UIKit

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    var resizedImageURL: URL {
        ///создаем строку из адреса
        let urlString = imageURL.absoluteString
        ///обрезаем лишнюю часть и добавляем модификатор желаемого качество
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        
        ///пытается создать новый адрес, если не получается возвращаем старый
        guard let newURL = URL(string: imageUrlString) else {
            return imageURL
        }
        return newURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
