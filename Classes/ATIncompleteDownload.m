//
//  ATIncompleteDownload.m
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "ATIncompleteDownload.h"


@implementation ATIncompleteDownload

@dynamic url;
@dynamic path;
@dynamic date;
@dynamic size;
@dynamic modDate;

+ downloadWithID:(sqlite_int64)uid
{
	return [[ATIncompleteDownload alloc] initWithID:uid];
}

- (id)init
{
	if (self = [super initWithTable:@"incomplete_downloads" entryID:0])
	{
	}
	
	return self;
}

- (id)initWithID:(sqlite_int64)uid
{
	if (self = [super initWithTable:@"incomplete_downloads" entryID:uid])
	{
	}
	
	return self;
}

@end
