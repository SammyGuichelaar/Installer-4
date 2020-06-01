//
//  ATSource.m
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "ATSource.h"
#import "ATDatabase.h"
#import "ATPackageIconFetch.h"
#import "ATPipelineManager.h"
#import "NSString+AppTappExtensions.h"
#import "NSFileManager+AppTappExtensions.h"

NSString* ATSourceUpdatedNotification = @"com.apptapp.install.source-updated";
NSString* ATSourceInfoIconChangedNotification = @"com.apptapp.install.source-icon.changed";

@implementation ATSource

@dynamic location;
@dynamic name;
@dynamic maintainer;
@dynamic contact;
@dynamic category;
@dynamic url;
@dynamic Description;
@dynamic isTrusted;
@dynamic lastrefresh;
@dynamic isUnsafe;
@dynamic hasErrors;
@dynamic iconURL;


+ (id)sourceWithID:(sqlite_int64)uid
{
    return [[ATSource alloc] initWithID:uid];
}

- (id)init
{
    if (self = [super initWithTable:@"sources" entryID:0])
    {
    }
    
    return self;
}

- (id)initWithID:(sqlite_int64)uid
{
    if (self = [super initWithTable:@"sources" entryID:uid])
    {
    }
    
    return self;
}

- (BOOL)isTrustedSource {
    return [self.isTrusted boolValue];
}

- (NSURL*)location
{
    return self.location;
}

- (void)remove
{
    if (self.entryID)
    {
#ifdef INSTALLER_APP
        [[ATDatabase sharedDatabase] executeUpdate:[NSString stringWithFormat:@"UPDATE packages SET source = NULL WHERE source = %u AND isInstalled = 1", self.entryID]];
#endif // INSTALLER_APP
        
        [[ATDatabase sharedDatabase] executeUpdate:[NSString stringWithFormat:@"DELETE FROM packages WHERE source = %lld AND isInstalled <> 1", self.entryID]];
    }
    
    [super remove];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"<ATSource: 0x%@ #%lld>", self, self.entryID];
}

#pragma mark -

#ifdef INSTALLER_APP

- (NSImage*)icon
{
    if (!self.iconURL)
        return nil;
    
    // Check if we have this icon cached already.
    NSString* cachedIconFileName = [[__ICON_CACHE_PATH__ stringByAppendingPathComponent:[[self.iconURL absoluteString] MD5Hash]] stringByAppendingPathExtension:@"png"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachedIconFileName])
        return [[[NSImage alloc] initWithContentsOfFile:cachedIconFileName] autorelease];
    
    [[NSFileManager defaultManager] createPath:__ICON_CACHE_PATH__ handler:nil];
    
    // Otherwise, queue the update up.
    ATPackageIconFetch* iconTask = [[[ATPackageIconFetch alloc] initWithPackage:nil source:self] autorelease];
    
    [[ATPipelineManager sharedManager] queueTask:iconTask forPipeline:ATPipelineMisc];
    
    return nil;
}

- (NSImage*)localIcon
{
    if (!self.iconURL)
        return nil;
    
    // Check if we have this icon cached already.
    NSString* cachedIconFileName = [[__ICON_CACHE_PATH__ stringByAppendingPathComponent:[[self.iconURL absoluteString] MD5Hash]] stringByAppendingPathExtension:@"png"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachedIconFileName])
        return [[[NSImage alloc] initWithContentsOfFile:cachedIconFileName] autorelease];
    
    return nil;
}

#else

- (UIImage*)icon
{
    if (!self.iconURL)
        return nil;
    
    // Check if we have this icon cached already.
    NSString* cachedIconFileName = [[__ICON_CACHE_PATH__ stringByAppendingPathComponent:[[self.iconURL absoluteString] MD5Hash]] stringByAppendingPathExtension:@"png"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachedIconFileName])
    {
        return [UIImage imageWithContentsOfFile:cachedIconFileName];
    }
    
    [[NSFileManager defaultManager] createPath:__ICON_CACHE_PATH__ handler:nil];
    
    // otherwise, queue the update up
    ATPackageIconFetch* iconTask = [[ATPackageIconFetch alloc] initWithPackage:nil source:self];
    
    [[ATPipelineManager sharedManager] queueTask:iconTask forPipeline:ATPipelineMisc];
    
    return nil;
}

- (UIImage*)localIcon
{
    if (!self.iconURL)
        return nil;
    
    // Check if we have this icon cached already.
    NSString* cachedIconFileName = [[__ICON_CACHE_PATH__ stringByAppendingPathComponent:[[self.iconURL absoluteString] MD5Hash]] stringByAppendingPathExtension:@"png"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachedIconFileName])
    {
        return [UIImage imageWithContentsOfFile:cachedIconFileName];
    }
    
    return nil;
}

#endif // INSTALLER_APP

@end
