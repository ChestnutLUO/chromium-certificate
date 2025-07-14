//
//  ContentView.swift
//  ChromiumCertificate
//
//  Created by Astrian Zheng on 14/7/2025.
//

import SwiftUI

struct StrokeText: ViewModifier {
	var strokeSize: CGFloat = 1
	var strokeColor: Color = .black
	
	func body(content: Content) -> some View {
		content
			.background(
				Rectangle()
					.foregroundColor(strokeColor)
					.mask(content)
					.blur(radius: strokeSize)
			)
	}
}

extension View {
	func stroke(color: Color = .black, width: CGFloat = 1) -> some View {
		modifier(StrokeText(strokeSize: width, strokeColor: color))
	}
}

struct ContentView: View {
	let count = ChromiumDetector.getChromiumAppCount()
	
	@State private var presentSheet: Bool = false
	
	var body: some View {
		ZStack {
			Image("AnnouncementBg").resizable().frame(width: 640, height: 480)
			VStack {
				Text(count != 0 ? "这台 Mac 上一共有 \(count) 个 Chromium" : "这台 Mac 一个 Chromium 都没有！")
					.font(.system(size: 35, weight: .semibold))
					.foregroundColor(Color("TextColor"))
					.stroke(color: Color("TextBorderColor"), width: 5)
				
				Button {
					self.presentSheet.toggle()
				} label: {
					Text("查看列表").font(.system(size: 20)).padding(.horizontal).padding(.vertical, 8)
				}
				.buttonStyle(.borderedProminent)
				.tint(.red)
				.sheet(isPresented: self.$presentSheet) {
					ChromiumBasedAppListView(isPresented: self.$presentSheet)
				}
			}
		}
		.frame(width: 640, height: 420)
	}
}

#Preview {
    ContentView()
}
