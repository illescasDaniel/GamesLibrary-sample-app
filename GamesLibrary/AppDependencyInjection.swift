//
//  AppDependencyInjection.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 7/5/26.
//

import HTTIES
import DIC
import Foundation

let di = DICBuilder()
	.registerSingleton(Environment.production)
	.registerSingleton(JSONDecoder())
	.register {
		URLSession.shared as any HTTPDataRequestHandler
	}
	.register {
		APIKeyRequestInterceptor(apiKey: ***REMOVED***)
	}
	.register {
		HTTPResponseLoggerInterceptor()
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
			networkDataSource: inject()
		) as any GamesRepository
	}
	.register {
		GetListOfGamesImpl(gamesRepository: inject()) as any GetListOfGames
	}
	.register {
		SearchGameImpl(gamesRepository: inject()) as any SearchGame
	}
	.register {
		GamesListViewModel(getListOfGames: inject(), searchGame: inject())
	}
	.build()

func inject<T>(_ type: T.Type = T.self) -> T {
	di.load(type)
}
