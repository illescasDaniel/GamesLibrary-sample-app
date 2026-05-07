//
//  TTLCache.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 7/5/26.
//

import Foundation

actor TTLCache<Key: Hashable & Sendable, Value: Sendable> {

	private var cache: [Key: Value] = [:]
	private var deletionTasks: [Key: Task<Void, Never>] = [:]

	private let timeToLive: Duration

	init(timeToLive: Duration) {
		self.timeToLive = timeToLive
	}

	func store(_ value: Value, forKey key: Key) {
		deletionTasks[key]?.cancel()
		cache[key] = value

		deletionTasks[key] = Task { [weak self, key, timeToLive] in
			do {
				try await Task.sleep(for: timeToLive)
				await self?.remove(forKey: key)
			} catch { }
		}
	}

	func value(forKey key: Key) -> Value? {
		return cache[key]
	}

	private func remove(forKey key: Key) {
		cache.removeValue(forKey: key)
		deletionTasks.removeValue(forKey: key)
	}
}
