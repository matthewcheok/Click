//
//  HighlightWindow.swift
//  Click
//
//  Created by Matthew Cheok on 1/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

import Cocoa

protocol HighlightWindowListener: class {
  func highlightWindow(clicked position: NSPoint)
  func highlightWindowPressedEscape()
}

class HighlightWindow: NSWindow {
  weak var listener: HighlightWindowListener?
  
  init() {
    super.init(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: false)
    self.backgroundColor = NSColor.red.withAlphaComponent(0.5)
    self.isOpaque = false
    self.level = Int(CGWindowLevelKey.screenSaverWindow.rawValue)
    self.hasShadow = false
  }
  
  override func mouseUp(with event: NSEvent) {
    super.mouseUp(with: event)
    listener?.highlightWindow(clicked: NSEvent.mouseLocation())
  }
  
  override func cancelOperation(_ sender: Any?) {
    super.cancelOperation(sender)
    listener?.highlightWindowPressedEscape()
  }
}
