//
//  NSRect+Helpers.swift
//  Click
//
//  Created by Matthew Cheok on 2/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

import Foundation

extension NSRect {  
  func convertedOriginToBottomLeft() -> NSRect {
    var copy = self
    let mainDisplayBounds = CGDisplayBounds(CGMainDisplayID())
    copy.origin.y = mainDisplayBounds.height - copy.origin.y - copy.size.height
    return copy
  }
}
