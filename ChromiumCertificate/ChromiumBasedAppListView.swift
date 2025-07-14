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
				Text("所有带有 Chromium 的应用程序").font(.headline)
				Spacer()
				Button {
					self.isPresented.toggle()
				} label: {
					Text("关闭")
				}
			}.padding()
			
			Divider()
			
			ScrollView {
				if chromiumAppsList.isEmpty {
					Text("你的电脑没有遭受 Chromium 的荼毒！望君继续努力。").multilineTextAlignment(.center).padding()
				}
				VStack(spacing: 8) {
					ForEach(Array(chromiumAppsList.enumerated()), id: \.element.id) { index, chromiumApp in
						HStack {
							VStack(alignment: .leading) {
								Text(chromiumApp.name).bold()
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
			}
		}.frame(width: 300).frame(minHeight: 0, maxHeight: 300)
	}
}

#Preview {
	ChromiumBasedAppListView(isPresented: .constant(true))
}
