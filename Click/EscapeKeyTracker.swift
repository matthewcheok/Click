//
//  EscapeKeyTracker.swift
//  Click
//
//  Created by Matthew Cheok on 2/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

protocol EscapeKeyTrackerDelegate: class {
  func escapeKeyTracker(tracked event: NSEvent)
}

class EscapeKeyTracker {
  weak var delegate: EscapeKeyTrackerDelegate?
  var enabled: Bool = false {
    didSet {
      guard oldValue != enabled else {
        return
      }
      
      if enabled {
        enable()
        print("listening for esc")
      } else {
        disable()
        print("stop listening for esc")
      }
    }
  }
  
  private var globalMonitor: Any?
  private var localMonitor: Any?
  
  deinit {
    disable()
  }
  
  private func enable() {
    globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown, handler: {
      [weak self]
      (event) in
      self?.process(event: event)
    })
    localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: {
      [weak self]
      (event) in
      self?.process(event: event)
      return event
    })
  }
  
  private func disable() {
    if let globalMonitor = globalMonitor {
      NSEvent.removeMonitor(globalMonitor)
    }
    if let localMonitor = localMonitor {
      NSEvent.removeMonitor(localMonitor)
    }
  }
  
  private func process(event: NSEvent) {
    print("key \(event.keyCode)")
    if Int(event.keyCode) == kVK_Escape {
      delegate?.escapeKeyTracker(tracked: event)
    }
  }
}
