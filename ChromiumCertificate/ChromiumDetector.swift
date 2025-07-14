//
//  ChromiumDetector.swift
//  ChromiumCertificate
//
//  Created by Astrian Zheng on 14/7/2025.
//

import Foundation

struct ChromiumApp: Identifiable {
	let id = UUID()
	let name: String
	let type: ChromiumType
	let path: String
}

enum ChromiumType: String, CaseIterable {
	case electron = "Electron"
	case chromium = "Chromium"
	case chromiumLibrary = "Chromium库"
	case electronIdentifier = "Electron标识"
}

class ChromiumDetector {
    
    static func detectChromiumApps() -> [ChromiumApp] {
        var chromiumApps: [ChromiumApp] = []
        let fileManager = FileManager.default
        let applicationsURL = URL(fileURLWithPath: "/Applications")
        
        do {
            let appURLs = try fileManager.contentsOfDirectory(
                at: applicationsURL,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
            
            for appURL in appURLs {
                if appURL.pathExtension == "app" {
                    if let chromiumApp = analyzeApp(at: appURL) {
                        chromiumApps.append(chromiumApp)
                    }
                }
            }
        } catch {
            print("Error reading applications directory: \(error)")
        }
        
        return chromiumApps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    private static func analyzeApp(at appURL: URL) -> ChromiumApp? {
        let appName = appURL.deletingPathExtension().lastPathComponent
        let contentsURL = appURL.appendingPathComponent("Contents")
        let frameworksURL = contentsURL.appendingPathComponent("Frameworks")
        let infoPlistURL = contentsURL.appendingPathComponent("Info.plist")
        
        // 检查 Electron Framework
        let electronFrameworkURL = frameworksURL.appendingPathComponent("Electron Framework.framework")
        if FileManager.default.fileExists(atPath: electronFrameworkURL.path) {
            return ChromiumApp(name: appName, type: .electron, path: appURL.path)
        }
        
        // 检查 Chromium 相关框架
        if hasChromiumFrameworks(at: frameworksURL) {
            return ChromiumApp(name: appName, type: .chromium, path: appURL.path)
        }
        
        // 检查可执行文件是否链接到 Chromium 库
        let executableURL = contentsURL.appendingPathComponent("MacOS").appendingPathComponent(appName)
        if hasChromiumLibraries(executablePath: executableURL.path) {
            return ChromiumApp(name: appName, type: .chromiumLibrary, path: appURL.path)
        }
        
        // 检查 Info.plist 中的 Electron 标识
        if hasElectronIdentifier(infoPlistPath: infoPlistURL.path) {
            return ChromiumApp(name: appName, type: .electronIdentifier, path: appURL.path)
        }
        
        return nil
    }
    
    private static func hasChromiumFrameworks(at frameworksURL: URL) -> Bool {
        do {
            let frameworks = try FileManager.default.contentsOfDirectory(atPath: frameworksURL.path)
            return frameworks.contains { $0.localizedCaseInsensitiveContains("chromium") }
        } catch {
            return false
        }
    }
    
    private static func hasChromiumLibraries(executablePath: String) -> Bool {
        guard FileManager.default.fileExists(atPath: executablePath) else { return false }
        
        let task = Process()
        task.launchPath = "/usr/bin/otool"
        task.arguments = ["-L", executablePath]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            return output.localizedCaseInsensitiveContains("chromium")
        } catch {
            return false
        }
    }
    
    private static func hasElectronIdentifier(infoPlistPath: String) -> Bool {
        guard FileManager.default.fileExists(atPath: infoPlistPath) else { return false }
        
        let task = Process()
        task.launchPath = "/usr/libexec/PlistBuddy"
        task.arguments = ["-c", "Print CFBundleIdentifier", infoPlistPath]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            return output.localizedCaseInsensitiveContains("electron")
        } catch {
            return false
        }
    }
    
    static func getChromiumAppCount() -> Int {
        return detectChromiumApps().count
    }
    
    static func getChromiumAppNames() -> [String] {
        return detectChromiumApps().map { $0.name }
    }
    
    static func getChromiumAppsByType() -> [ChromiumType: [ChromiumApp]] {
        let apps = detectChromiumApps()
        var groupedApps: [ChromiumType: [ChromiumApp]] = [:]
        
        for type in ChromiumType.allCases {
            groupedApps[type] = apps.filter { $0.type == type }
        }
        
        return groupedApps
    }
}
