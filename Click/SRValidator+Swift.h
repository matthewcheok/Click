//
//  SRValidator+Swift.h
//  Click
//
//  Created by Matthew Cheok on 5/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

#import <ShortcutRecorder/ShortcutRecorder.h>

@interface SRValidator (Swift)

- (BOOL)isKeyCode:(unsigned short)aKeyCode andFlagsAvailable:(NSEventModifierFlags)aFlags error:(NSError **)outError;

@end
