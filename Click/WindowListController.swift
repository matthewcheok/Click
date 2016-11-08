//
//  WindowListController.swift
//  Click
//
//  Created by Matthew Cheok on 1/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

import Cocoa

struct Window: Equatable {
  let name: String
  let number: Int
  let level: Int
  let bounds: NSRect
  let displays: [Display]
}

struct Display: Equatable {
  let number: CGDirectDisplayID
  let bounds: NSRect
}

func ==(lhs: Window, rhs: Window) -> Bool {
  return lhs.number == rhs.number
}

func ==(lhs: Display, rhs: Display) -> Bool {
  return lhs.number == rhs.number
}

class WindowListController {
  var windows = [Window]()
  
  init() {
    refreshList()
  }
  
  private func displaysForRect(rect: NSRect) -> [Display] {
    let maxDisplays: UInt32 = 16
    var count: UInt32 = 0
    var displayIDs = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
    CGGetDisplaysWithRect(rect, maxDisplays, &displayIDs, &count)
    return displayIDs[0..<Int(count)].map { Display(number: $0, bounds: CGDisplayBounds($0)) }
  }
  
  func refreshList() {
    let options: CGWindowListOption = [.optionAll, .optionOnScreenOnly, .excludeDesktopElements]
    guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
      return
    }
    
    windows = list.map {
      (window: [String: Any]) -> Window in
      let ownerName: String = window[kCGWindowOwnerName as String] as? String ?? ""
      let windowName: String = window[kCGWindowName as String] as? String ?? ""
      let name = "\(ownerName) - \(windowName)"
      
      guard let number = window[kCGWindowNumber as String] as? Int else {
        fatalError()
      }

      guard let level = window[kCGWindowLayer as String] as? Int else {
        fatalError()
      }

      guard let boundsDictionary = window[kCGWindowBounds as String] as? NSDictionary else {
        fatalError()
      }
      guard let bounds = NSRect(dictionaryRepresentation: boundsDictionary) else {
        fatalError()
      }
      
      let displays = displaysForRect(rect: bounds)
      return Window(name: name, number: number, level: level, bounds: bounds, displays: displays)
    }.filter({ (window) -> Bool in
      window.level == 0
    })
  }
}
