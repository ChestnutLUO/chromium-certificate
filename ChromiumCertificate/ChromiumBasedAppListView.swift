//
//  ChromiumBasedAppListView.swift
//  ChromiumCertificate
//
//  Created by Astrian Zheng on 14/7/2025.
//

import SwiftUI

struct ChromiumBasedAppListView: View {
	@Binding var isPresented: Bool
	
	let chromiumAppsList: [ChromiumApp] = ChromiumDetector.detectChromiumApps()
	
	var body: some View {
		VStack(spacing: 0) {
			HStack {
				Text("LISTVIEW_TITLE").font(.headline)
				Spacer()
				Button {
					self.isPresented.toggle()
				} label: {
					Text("LISTVIEW_CLOSE")
				}
			}.padding()
			
			Divider()
			
			ScrollView {
				if chromiumAppsList.isEmpty {
					Text("LISTVIEW_NO_CHRIMIUM_APPS_FOUND").multilineTextAlignment(.center).padding()
				}
				VStack(spacing: 8) {
					ForEach(Array(chromiumAppsList.enumerated()), id: \.element.id) { index, chromiumApp in
						HStack {
							VStack(alignment: .leading) {
								HStack {
									if let isTahoeFixed = chromiumApp.isTahoeFixed {
										Text(isTahoeFixed ? "✅" : "❌")
									}
									Text(chromiumApp.name).bold()
								}
								if let version = chromiumApp.electronVersion {
									Text("Electron \(version)")
										.font(.system(.caption, design: .monospaced))
								}
								Text(chromiumApp.path)
									.font(.system(.caption, design: .monospaced))
							}
							Spacer()
						}
						
						if index < chromiumAppsList.count - 1 {
							Divider()
						}
					}
				}.padding()

				if chromiumAppsList.contains(where: { $0.isTahoeFixed != nil }) {
					Divider()
					VStack(alignment: .leading, spacing: 4) {
						Text("关于 macOS Sequoia 性能问题：").font(.caption).bold()
						Text("✅ = Electron 版本已修复（≥36.9.2, ≥37.6.0, ≥38.2.0, ≥39.0.0）").font(.caption2)
						Text("❌ = Electron 版本存在性能问题").font(.caption2)
					}.padding().frame(maxWidth: .infinity, alignment: .leading)
				}
			}
		}.frame(width: 300).frame(minHeight: 0, maxHeight: 300)
	}
}

#Preview("中文") {
	ChromiumBasedAppListView(isPresented: .constant(true))
		.environment(\.locale, Locale(identifier: "zh-Hans"))
}

#Preview("English") {
	ChromiumBasedAppListView(isPresented: .constant(true))
		.environment(\.locale, Locale(identifier: "en"))
}

#Preview("日本語") {
	ChromiumBasedAppListView(isPresented: .constant(true))
		.environment(\.locale, Locale(identifier: "ja"))
}
