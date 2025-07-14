//
//  ChromiumCertificateApp.swift
//  ChromiumCertificate
//
//  Created by Astrian Zheng on 14/7/2025.
//

import SwiftUI

@main
struct ChromiumCertificateApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
		.windowResizability(.contentSize)
		.defaultSize(width: 640, height: 480)
		.windowStyle(.hiddenTitleBar)
	}
}
