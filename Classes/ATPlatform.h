// AppTapp Framework
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//


@interface ATPlatform : NSObject {
}

+ (NSString *)platformName;
+ (NSString *)firmwareVersion;
+ (NSString *)deviceName;
+ (NSString *)deviceUUID;
+ (NSString *)applicationsPath;
+ (BOOL)isDeviceRootLocked;

@end
