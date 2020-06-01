//
//  ATURLDownload.m
//  Installer
//
//  Created by Slava Karpenko on 7/10/08.
//  Copyright 2008 RiP Dev. All rights reserved.
//

#import "ATURLDownload.h"
#import "ATPlatform.h"
#import "NSFileManager+AppTappExtensions.h"
#import "ATPackageManager.h"
#import "ATIncompleteDownload.h"
#import "ATIncompleteDownloads.h"
#import "NSURL+AppTappExtensions.h"
#import <CoreFoundation/CoreFoundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#ifdef INSTALLER_APP
#import "IAPhoneManager.h"
#else
#import <CFNetwork/CFProxySupport.h>
#endif // INSTALLER_APP

#define kATURLDownloadTimeout        600            // 10 minutes oughtta be enough for everybody...

static NSURLSession* sSharedURLSession = nil;

@interface ATURLDownload ()

@property (nonatomic, retain) NSURLSessionDownloadTask* downloadTask;

@end

@implementation ATURLDownload

@synthesize downloadFile;
@synthesize downloadFilePath;
@synthesize delegate;
@synthesize url;
@synthesize cancel;
@synthesize refcon;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)del
{
    return [self initWithRequest:request delegate:del resumeable:NO userAgent:nil];
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)del userAgent:(NSString*)agent
{
    return [self initWithRequest:request delegate:del resumeable:NO userAgent:agent];
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)del resumeable:(BOOL)resumeable
{
    return [self initWithRequest:request delegate:del resumeable:resumeable userAgent:nil];
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)del resumeable:(BOOL)resumeable userAgent:(NSString*)agent
{
    if (self = [super init])
    {
        userAgent = [agent copy];
        
        cancel = NO;
        self.delegate = del;
        
        self.url = [request URL];
        
        if ([self.url isFileURL])
        {
            // woot
            self.downloadFilePath = [[NSFileManager defaultManager] tempFilePath];
            if ([delegate respondsToSelector:@selector(downloadDidBegin:)])
                [delegate downloadDidBegin:self];
            if ([delegate respondsToSelector:@selector(download:didCreateDestination:)])
                [delegate download:self didCreateDestination:self.downloadFilePath];
            
            if ([[NSFileManager defaultManager] copyItemAtPath:[url path] toPath:self.downloadFilePath error:nil])
            {
                if ([self.delegate respondsToSelector:@selector(downloadDidFinish:)])
                    [self.delegate downloadDidFinish:self];
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(download:didFailWithError:)])
                    [self.delegate download:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil]];
                
            }
            
            return self;
        }
        
        if (self.downloadFilePath == nil)
            self.downloadFilePath = [[NSFileManager defaultManager] tempFilePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([delegate respondsToSelector:@selector(downloadDidBegin:)])
                [delegate downloadDidBegin:self];

            if ([delegate respondsToSelector:@selector(download:didCreateDestination:)])
                [delegate download:self didCreateDestination:self.downloadFilePath];
        });

        if (sSharedURLSession == nil) {
            NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
            
            sSharedURLSession = [NSURLSession sessionWithConfiguration:config];
        }
        
        self.downloadTask = [sSharedURLSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (location != nil) {
                [[NSFileManager defaultManager] copyItemAtURL:location toURL:[NSURL fileURLWithPath:self.downloadFilePath] error:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(downloadDidFinish:)])
                        [self.delegate downloadDidFinish:self];
                });
            } else if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(download:didFailWithError:)])
                        [self.delegate download:self didFailWithError:error];
                });
            }
        }];
        [self.downloadTask resume];
    }
    
    return self;
}

- (void)dealloc
{
    [self.downloadFile closeFile];
    self.downloadFile = nil;
    self.downloadFilePath = nil;
    
    self.downloadTask = nil;
    self.url = nil;
}

- (void)cancelDownload
{
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {}];
}

@end
