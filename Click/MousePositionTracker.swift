//
//  MousePositionTracker.swift
//  Click
//
//  Created by Matthew Cheok on 1/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

import Cocoa

protocol MousePositionTrackerDelegate: class {
  func mousePositionTracker(tracked position: NSPoint)
}

class MousePositionTracker {
  weak var delegate: MousePositionTrackerDelegate?
  var enabled: Bool = false {
    didSet {
      guard oldValue != enabled else {
        return
      }
      
      if enabled {
        enable()
      } else {
        disable()
      }
    }
  }
  
  private var globalMonitor: Any?
  private var localMonitor: Any?
  
  deinit {
    disable()
  }
  
  var currentPosition: NSPoint {
    let localPosition = NSEvent.mouseLocation()
    let globalPosition = NSPoint(x: localPosition.x, y: CGDisplayBounds(CGMainDisplayID()).height - localPosition.y)
    return globalPosition
  }
  
  private func enable() {
    globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved, handler: {
      [weak self]
      (event) in
      self?.process(event: event)
    })
    localMonitor = NSEvent.addLocalMonitorForEvents(matching: .mouseMoved, handler: {
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
    delegate?.mousePositionTracker(tracked: currentPosition)
  }
}
