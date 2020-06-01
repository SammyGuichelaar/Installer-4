// AppTapp Framework
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "NSDate+AppTappExtensions.h"


@implementation NSDate (AppTappExtensions)

+ (NSDate *)dateWithDOSDate:(unsigned long int)dosDate {
	int gmtDiff = (int)[[NSTimeZone systemTimeZone] secondsFromGMT];
	NSString * timeZone = [NSString stringWithFormat:@"%@%04i",(gmtDiff<0)?@"-":@"+", gmtDiff];
    
    // YYYY-MM-DD HH:MM:SS
    NSString * dateString = [NSString stringWithFormat:@"%4li-%02li-%02li %02li:%02li:%02li %@",
			                (((dosDate>>25)&0x7F)+1980), // year
                			((dosDate>>21)&0xF), // month
			                ((dosDate>>16)&0x1F), // day
			                ((dosDate>>11)&0x1F), // hour
			                ((dosDate>>5)&0x3F), // minutes
			                ((dosDate)&0x1F), // seconds
			                timeZone]; // time zone (local)

    SEL dateWithString = NSSelectorFromString(@"dateWithString:");
    return [NSDate performSelector:dateWithString withObject:dateString];
}

@end
