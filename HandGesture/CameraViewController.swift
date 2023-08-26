//
//  CameraViewController.swift
//  HandGesture
//
//  Created by Yos Hashimoto on 2023/07/30.
//

import UIKit
import AVFoundation
import Vision

// MARK: CameraViewController

class CameraViewController: UIViewController {
	
	@IBOutlet weak var textView: UITextView!
	
#if os(visionOS)
	private var gestureProvider: VisionGestureProvider?
#else
	private var gestureProvider: SpatialGestureProvider?
#endif
	override func viewDidLoad() {
		super.viewDidLoad()
		textView.text = ""
		textLog("Ready...")
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		#if os(visionOS)
		gestureProvider = VisionGestureProvider(baseView: self.view)
		//gestureProvider?.appendGesture(Gesture_Cursor(delegate: self))

		Task {
			await prepareGesture()
		}

		#else
		gestureProvider = SpatialGestureProvider(baseView: self.view)
		gestureProvider?.appendGesture(Gesture_Cursor(delegate: self))
//		gestureProvider?.appendGesture(Gesture_Draw(delegate: self))
//		gestureProvider?.appendGesture(Gesture_Heart(delegate: self))
//		gestureProvider?.appendGesture(Gesture_Aloha(delegate: self))
//		gestureProvider?.appendGesture(Gesture_Gun(delegate: self))
		#endif
	}
	
	override func viewDidLayoutSubviews() {
		gestureProvider?.layoutSubviews()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		gestureProvider?.terminate()
		super.viewWillDisappear(animated)
	}
		
#if os(visionOS)
	func prepareGesture() async {
		await gestureProvider?.start()
		await gestureProvider?.publishHandTrackingUpdates()
		await gestureProvider?.monitorSessionEvents()
	}
#endif
}

// MARK: SpecialGestureDelegate

#if os(visionOS)
extension CameraViewController: VisionGestureDelegate {
	func gestureBegan(gesture: VisionGestureProcessor, atPoints:[CGPoint]) {
		textLog("Gesture[\(String(describing: type(of: gesture)))] began")
//		textView.text = textView.text+"\r"+"Gesture[\(String(describing: type(of: gesture)))] began"
	}
	func gestureMoved(gesture: VisionGestureProcessor, atPoints:[CGPoint]) {
	}
	func gestureFired(gesture: VisionGestureProcessor, atPoints:[CGPoint], triggerType: Int) {
		if gesture is VisionGesture_Cursor {
			let cursor: Gesture_Cursor.CursorType = Gesture_Cursor.CursorType(rawValue: triggerType)!
			switch cursor {
			case .up:
				textLog("UP")
			case .down:
				textLog("DOWN")
			case .right:
				textLog("RIGHT")
			case .left:
				textLog("LEFT")
			case .fire:
				textLog("FIRE")
			default:
				break
			}
		}
	}
	func gestureEnded(gesture: VisionGestureProcessor, atPoints:[CGPoint]) {
	}
	func gestureCanceled(gesture: VisionGestureProcessor, atPoints:[CGPoint]) {
	}
	
	func textLog(_ message: String) {
		textView.isScrollEnabled = false
		textView.text = message+"\r"+textView.text
	}

}
#else
extension CameraViewController: SpatialGestureDelegate {
	func gestureBegan(gesture: SpatialGestureProcessor, atPoints:[CGPoint]) {
		print("Gesture[\(String(describing: type(of: gesture)))] began")
	}
	func gestureMoved(gesture: SpatialGestureProcessor, atPoints:[CGPoint]) {
		gestureProvider?.cameraView.showPoints(atPoints, color: #colorLiteral(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0))
		if gesture is Gesture_Draw {
			guard let point = atPoints.first else { return }
			gestureProvider?.cameraView.updatePath(with: point, isLastPoint: false)
		}
	}
	func gestureFired(gesture: SpatialGestureProcessor, atPoints:[CGPoint], triggerType: Int) {
		gestureProvider?.cameraView.showPoints(atPoints, color: #colorLiteral(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0))
		if gesture is Gesture_Draw {
			if triggerType == Gesture_Draw.TriggerType.canvasClear.rawValue {
				gestureProvider?.cameraView.clearPath()
			}
		}
		if gesture is Gesture_Cursor {
			var cursor: Gesture_Cursor.CursorType = Gesture_Cursor.CursorType(rawValue: triggerType)!
			switch cursor {
			case .up:
				print("UP")
			case .down:
				print("DOWN")
			case .right:
				print("RIGHT")
			case .left:
				print("LEFT")
			case .fire:
				print("FIRE")
			default:
				break
			}
			if triggerType == Gesture_Draw.TriggerType.canvasClear.rawValue {
				gestureProvider?.cameraView.clearPath()
			}
		}
	}
	func gestureEnded(gesture: SpatialGestureProcessor, atPoints:[CGPoint]) {
		gestureProvider?.cameraView.clearPoints()
		print("Gesture[\(String(describing: type(of: gesture)))] ended")
		if gesture is Gesture_Draw {
			guard let point = atPoints.first else { return }
			gestureProvider?.cameraView.updatePath(with: point, isLastPoint: true)
		}
	}
	func gestureCanceled(gesture: SpatialGestureProcessor, atPoints:[CGPoint]) {
		gestureProvider?.cameraView.clearPoints()
		if gesture is Gesture_Draw {
			guard let point = atPoints.first else { return }
			gestureProvider?.cameraView.updatePath(with: point, isLastPoint: true)
		}
	}
	
}
#endif
