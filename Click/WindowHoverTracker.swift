//
//  WindowHoverTracker.swift
//  Click
//
//  Created by Matthew Cheok on 2/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

import Foundation

protocol WindowHoverTrackerDelegate: class {
  func windowHoverTracker(tracked window: Window)
}

class WindowHoverTracker: MousePositionTrackerDelegate {
  weak var delegate: WindowHoverTrackerDelegate?
  var enabled: Bool = false {
    didSet {
      guard oldValue != enabled else {
        return
      }
      
      mousePositionTracker.enabled = enabled
      if enabled {
        windowListController.refreshList()
        searchWindows(position: mousePositionTracker.currentPosition)
      }
    }
  }
  
  private let windowListController = WindowListController()
  private let mousePositionTracker = MousePositionTracker()
  
  init() {
    mousePositionTracker.delegate = self
  }
  
  private func searchWindows(position: NSPoint) {
    for window in windowListController.windows {
      if window.bounds.contains(position) {
        delegate?.windowHoverTracker(tracked: window)
        return
      }
    }
  }
  
  // MARK: - MousePositionTrackerDelegate
  func mousePositionTracker(tracked position: NSPoint) {
    searchWindows(position: position)
  }
}
