//
//  LoadingView.swift
//  GamesLibrary
//
//  Created by Daniel Illescas Romero on 8/5/26.
//

import SwiftUI

struct LoadingView: View {

	let titleKey: LocalizedStringKey

	init(_ titleKey: LocalizedStringKey = "Loading...") {
		self.titleKey = titleKey
	}

	var body: some View {
		ProgressView(titleKey)
			.controlSize(.regular)
			.padding(24)
			.background(.ultraThinMaterial)
			.foregroundColor(.primary)
			.clipShape(RoundedRectangle(cornerRadius: 16))
			.overlay(
				RoundedRectangle(cornerRadius: 16)
					.stroke(
						LinearGradient(
							colors: [.white.opacity(0.6), .clear, .white.opacity(0.2)],
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						),
						lineWidth: 1.5
					)
			)
			.shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
	}
}
