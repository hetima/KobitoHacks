//
//  KobitoHacks.h
//  KobitoHacks


#import <Cocoa/Cocoa.h>

@interface KHSimblLoader : NSObject

@end


@interface KHResourceLoadDelegate : NSObject
+ (KHResourceLoadDelegate*)sharedInstance;

@end