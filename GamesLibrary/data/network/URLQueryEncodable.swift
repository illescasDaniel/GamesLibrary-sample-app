//
//  URLQueryEncodable.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import Foundation

protocol URLQueryEncodable {
	var queryItems: [URLQueryItem] { get }
}
