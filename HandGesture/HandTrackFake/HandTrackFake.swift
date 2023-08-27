//
//  HandTrackFake.swift
//  HandGesture
//
//  Created by Yos Hashimoto on 2023/08/27.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

struct HandTrackFake {
	private let fileManager = FileManager.default
	private var fakeRootDirectory = ""

	init() {
		// /Users/yoshiyuki/Library/Containers/com.newtonjapan.apple-samplecode.HandPose/Data/HandTrackFake/handtrack.json
		fakeRootDirectory = NSHomeDirectory() + "/HandTrackFake"
		createDirectory(atPath: fakeRootDirectory)
	}
	
	// MARK: file management
	private func convertPath(_ path: String) -> String {
		if path.hasPrefix("/") {
			return fakeRootDirectory + path
		}
		return fakeRootDirectory + "/" + path
	}

	func createDirectory(atPath path: String) {
		if fileExists(atPath: path) {
			return
		}
		do {
		   try fileManager.createDirectory(atPath: convertPath(path), withIntermediateDirectories: true, attributes: nil)
		} catch let error {
			print(error.localizedDescription)
		}
	}

	func createFile(atPath path: String, contents: String) {
		createFile(atPath: path, contents: contents.data(using: .utf8))
	}

	func createFile(atPath pathS: String, contents: Data?) {
		let path = convertPath(pathS)
		if fileExists(atPath: path) {
			print("already exists file: \(NSString(string: path))")
			return
		}
		if !fileManager.createFile(atPath: convertPath(path), contents: contents, attributes: nil) {
			print("Create file error")
		}
	}
	
	func writeFile(atPath path: String, contents: String) {
		do {
			let path = convertPath(path)
			let url: URL = URL(fileURLWithPath: path)
			try contents.write(to: url, atomically: false, encoding: .utf8)
		}
		catch {}
	}

	func readFile(atPath path: String) -> String {
		var retStr = ""
		let path = convertPath(path)
		if !fileExists(atPath: path) {
			print("file not exist: \(NSString(string: path))")
			retStr = ""
		}
		do {
			let url: URL = URL(fileURLWithPath: path)
			retStr = try String(contentsOf: url, encoding: .utf8)
		}
		catch {
		}
		return retStr
	}
	
	func fileExists(atPath path: String) -> Bool {
		return fileManager.fileExists(atPath: convertPath(path))
	}


}

