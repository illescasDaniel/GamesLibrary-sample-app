//
//  AppDependencyInjection.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 7/5/26.
//

import HTTIES
import DIC
import Foundation
import BetterLogger

let di = DICBuilder()
// MARK: data
	.registerSingleton(Environment.production)
	.registerSingleton(JSONDecoder())
	.registerSingleton(BetterLogger(name: "App"))
	.register {
		URLSession.shared as any HTTPDataRequestHandler
	}
	.register {
		APIKeyRequestInterceptor(
			apiKey: inject(Environment.self).apiKey,
			logger: inject()
		)
	}
	.register {
		HTTPResponseLoggerInterceptor(logger: inject())
	}
	.registerSingleton {
		HTTPClientImpl(
			httpDataRequestHandler: inject(),
			requestInterceptors: [
				inject(APIKeyRequestInterceptor.self)
			],
			responseInterceptors: [
				inject(HTTPResponseLoggerInterceptor.self)
			]
		) as any HTTPClient
	}
	.register {
		GamesNetworkDataSourceImpl(
			httpClient: inject(),
			environment: inject(),
			jsonDecoder: inject(),
		) as any GamesNetworkDataSource
	}
	.register {
		GamesCacheDataSourceImpl() as any GamesCacheDataSource
	}
	.register {
		GamesRepositoryImpl(
			cacheDataSource: inject(),
			networkDataSource: inject(),
			logger: inject()
		) as any GamesRepository
	}
// MARK: domain
	.register {
		GetListOfGamesImpl(gamesRepository: inject()) as any GetListOfGames
	}
	.register {
		SearchGameImpl(gamesRepository: inject()) as any SearchGame
	}
	.register {
		GetGameDetailsImpl(gamesRepository: inject()) as any GetGameDetails
	}
// MARK: presentation
	.register {
		GamesListViewModel(
			getListOfGames: inject(),
			searchGame: inject(),
			logger: inject()
		)
	}
	.register {
		GameDetailsViewModel(
			getGameDetails: inject(),
			logger: inject()
		)
	}
	.build()

func inject<T>(_ type: T.Type = T.self) -> T {
	di.load(type)
}
