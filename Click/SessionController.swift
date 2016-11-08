//
//  WindowHighlightController.swift
//  Click
//
//  Created by Matthew Cheok on 2/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

import Cocoa

protocol SessionControllerDelegate: class {
  func sessionController(didUpdateTo state: SessionController.State)
}

class SessionController: NSObject, WindowHoverTrackerDelegate, HighlightWindowListener, WindowRecorderDelegate, EscapeKeyTrackerDelegate {
  enum State {
    case ready
    case selecting
    case waiting
    case recording
  }
  
  private let escapeKeyTracker = EscapeKeyTracker()
  private let hoverTracker = WindowHoverTracker()
  private let highlightWindow = HighlightWindow()
  
  private var currentWindow: Window?
  private var windowRecorder: WindowRecorder?
  
  weak var delegate: SessionControllerDelegate?
  private(set) var state: State = .ready {
    didSet {
      guard oldValue != state else {
        return
      }
      
      delegate?.sessionController(didUpdateTo: state)
      
      if case .selecting = state {
        escapeKeyTracker.enabled = true
        hoverTracker.enabled = true
        highlightWindow.makeKeyAndOrderFront(self)
      } else {
        escapeKeyTracker.enabled = false
        hoverTracker.enabled = false
        highlightWindow.orderOut(self)
      }
    }
  }
  
  override init() {
    super.init()
    escapeKeyTracker.delegate = self
    highlightWindow.listener = self
    hoverTracker.delegate = self
    
    guard let desktopUrl = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
      fatalError()
    }
    
    let defaults: [String: Any] = [
      PreferenceKey.quality.rawValue: WindowRecorder.Quality.high.rawValue,
      PreferenceKey.saveUrl.rawValue: desktopUrl,
    ]
    UserDefaults.standard.register(defaults: defaults)
    NSUserDefaultsController.shared().initialValues = defaults
  }
  
  func beginRecording() {
    state = .selecting
  }
  
  func cancelRecording() {
    state = .ready
    windowRecorder?.stop()
  }
  
  func stopRecording() {
    windowRecorder?.stop()
  }
  
  // MARK: - WindowHoverTrackerDelegate
  
  func windowHoverTracker(tracked window: Window) {
    if let current = currentWindow,
      current == window {
        return
    }
    
    currentWindow = window
    let convertedWindowBounds = window.bounds.convertedOriginToBottomLeft()
    highlightWindow.setContentSize(convertedWindowBounds.size)
    highlightWindow.setFrameOrigin(convertedWindowBounds.origin)
  }
  
  // MARK: - HighlightWindowListener
  
  func highlightWindow(clicked position: NSPoint) {
    guard let currentWindow = currentWindow else {
      return
    }
    
    guard let qualityString = UserDefaults.standard.string(forKey: PreferenceKey.quality.rawValue) else {
      fatalError("Cannot load recording quality")
    }

    let quality = WindowRecorder.Quality(rawValue: qualityString) ?? WindowRecorder.Quality.high
    
    guard let destinationUrl = UserDefaults.standard.url(forKey: PreferenceKey.saveUrl.rawValue) else {
      fatalError("Cannot find destination location")
    }
    
    state = .waiting
    let recorder = WindowRecorder(window: currentWindow)
    recorder.delegate = self
    recorder.record(to: destinationUrl, quality: quality)
    windowRecorder = recorder
  }
  
  func highlightWindowPressedEscape() {
    state = .ready
  }
  
  // MARK: - WindowRecorderDelegate
  
  func windowRecorderStartedRecording() {
    state = .recording
  }
  
  func windowRecorderFinishedRecording(url: URL) {
    state = .ready
    windowRecorder = nil
  }
 
  // MARK: - EscapeKeyTrackerDelegate
  
  func escapeKeyTracker(tracked event: NSEvent) {
    state = .ready
  }
  
}
