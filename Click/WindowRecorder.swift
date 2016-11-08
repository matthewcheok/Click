//
//  WindowRecorder.swift
//  Click
//
//  Created by Matthew Cheok on 2/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

import Cocoa
import AVFoundation

protocol WindowRecorderDelegate: class {
  func windowRecorderStartedRecording()
  func windowRecorderFinishedRecording(url: URL)
}

final class WindowRecorder: NSObject, AVCaptureFileOutputRecordingDelegate {
  enum Quality: String {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    static var allValues: [String] {
      let values: [Quality] = [.high, .medium, .low]
      return values.map { $0.rawValue }
    }
    
    var string: String {
      switch self {
      case .high:
        return AVCaptureSessionPresetHigh
      case .medium:
        return AVCaptureSessionPresetMedium
      case .low:
        return AVCaptureSessionPresetLow
      }
    }
  }
  
  weak var delegate: WindowRecorderDelegate?
  
  let captureSession: AVCaptureSession
  let input: AVCaptureScreenInput
  let output: AVCaptureMovieFileOutput
  
  var saveUrl: URL?
  
  init(window: Window) {
    captureSession = AVCaptureSession()
    captureSession.sessionPreset = AVCaptureSessionPresetHigh
    guard let display = window.displays.first else {
      fatalError()
    }
    
    input = AVCaptureScreenInput(displayID: display.number)
    input.cropRect = window.bounds.convertedOriginToBottomLeft()
    guard captureSession.canAddInput(input) else {
      fatalError()
    }
    captureSession.addInput(input)
    
    output = AVCaptureMovieFileOutput()
    guard captureSession.canAddOutput(output) else {
      fatalError()
    }
    captureSession.addOutput(output)
    
    super.init()
  }
  
  func record(to destinationUrl: URL, quality: Quality = .high) {
    captureSession.sessionPreset = quality.string
    let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory())
    let fileUrl = tempUrl.appendingPathComponent("\(NSUUID().uuidString).mov")
    saveUrl = destinationUrl.appendingPathComponent(fileUrl.lastPathComponent)

    captureSession.startRunning()
    output.startRecording(toOutputFileURL: fileUrl, recordingDelegate: self)
  }
  
  func stop() {
    output.stopRecording()
  }
  
  // MARK: - AVCaptureFileOutputRecordingDelegate
  
  func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
    delegate?.windowRecorderStartedRecording()
  }
  
  func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
    captureSession.stopRunning()
    
    guard let outputUrl = outputFileURL else {
      fatalError()
    }
    
    if let saveUrl = saveUrl {
      do {
        try FileManager.default.moveItem(at: outputUrl, to: saveUrl)
      }
      catch {
        print(error)
      }
    }

    delegate?.windowRecorderFinishedRecording(url: saveUrl ?? outputUrl)
  }
}
