//
//  Array+Helpers.swift
//  Click
//
//  Created by Matthew Cheok on 2/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

import Foundation

extension Array {
  
  init<Size: Integer>(
    fillingBufferOfSize maxSize: Size,
    fillBuffer: (UnsafeMutablePointer<Element>, inout Size) throws -> ()) rethrows
  {
    let maxSizeAsInt = Int(maxSize.toIntMax())
    let buf = UnsafeMutablePointer<Element>.allocate(capacity: maxSizeAsInt)
    defer { buf.deallocate(capacity: maxSizeAsInt) }
    
    var actualCount: Size = 0
    try fillBuffer(buf, &actualCount)
    
    self.init(UnsafeBufferPointer(start: buf, count: Int(actualCount.toIntMax())))
  }
  
}
