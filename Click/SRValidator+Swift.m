//
//  SRValidator+Swift.m
//  Click
//
//  Created by Matthew Cheok on 5/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

#import "SRValidator+Swift.h"

@implementation SRValidator (Swift)

- (BOOL)isKeyCode:(unsigned short)aKeyCode andFlagsAvailable:(NSEventModifierFlags)aFlags error:(NSError **)outError
{
  return ![self isKeyCode:aKeyCode andFlagsTaken:aFlags error:outError];
}

@end
