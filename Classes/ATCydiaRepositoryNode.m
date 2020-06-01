//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

/*********        includes        *********/

#import <stdio.h>
#import <fcntl.h>
#import "ATCydiaRepositoryNode.h"
#import "ATURLDownload.h"
#import "EXArray.h"

/*********        forward declarations, globals and typedefs        *********/

static NSArray* sExtensions = nil;
static NSArray* sFolderOrder = nil;

NSString* const ATCydiaSourceStandardReleasePath = @"/dists/stable/";
NSString* const ATCydiaSourceStandardPackagesPath = @"/dists/stable/main/binary-iphoneos-arm/";
NSString* const ATCydiaSourcePackagesFileName = @"/Packages";
NSString* const ATCydiaSourceReleaseFileName = @"/Release";
NSString* const ATCydiaUserAgent = @"Cydia/0.9 CFNetwork/342.1 Darwin/9.4.1";

/*********        private interface for ATCydiaRepositoryNode        *********/

@interface ATCydiaRepositoryNode (Private)

- (void)setParent:(ATCydiaRepositoryNode*)parent;

- (NSArray*)extensions;
- (NSArray*)folderOrder;

- (void)startNodePackagesScanWithExtension:(NSString*)ext;
- (void)startReleaseScan;
- (BOOL)shouldContinueScan;
- (void)startNodeHTMLDownload;
- (void)startChildrenScan;
- (void)callScanDidFinish;
- (void)scanDidFinishInNode:(ATCydiaRepositoryNode*)node;
- (BOOL)checkPackagesReleaseFile:(NSString*)filePath;
- (NSComparisonResult)compareNodes:(ATCydiaRepositoryNode*)node;
- (BOOL)checkFolderName;

@end

#pragma mark -

/*********        implementation for ATCydiaRepositoryNode        *********/

@implementation ATCydiaRepositoryNode

@synthesize _delegate;
@synthesize _url;

- (id)initWithURL:(NSURL*)url nodeHTMLFilePath:(NSString*)nodeHTMLPath
{
    self = [super init];

    if (self)
    {
        _url = [url copy];
        _mode = ATCydiaRepositoryNodeNotScanMode;

        if (nodeHTMLPath != nil)
        {
             NSError *_error;
            _nodeHTML = [[NSString alloc] initWithContentsOfFile:nodeHTMLPath encoding:NSUTF8StringEncoding error:&_error];
        }
    }

    return self;
}

- (void)finalize
{
    if (_tempFileName != nil)
        [[NSFileManager defaultManager] removeItemAtPath:_tempFileName error:nil];

    if (_urlDownload.delegate == self)
        _urlDownload.delegate = nil;

    [super finalize];
}

- (void)dealloc
{
    if (_tempFileName != nil)
    {
        [[NSFileManager defaultManager] removeItemAtPath:_tempFileName error:nil];
    }
    if (_urlDownload.delegate == self)
    {
        _urlDownload.delegate = nil;
    }
}

#pragma mark -
#pragma mark *** Public methods ***
#pragma mark -

- (void)startScan
{
    if (_url != nil && _mode == ATCydiaRepositoryNodeNotScanMode)
    {
        _mode = ATCydiaRepositoryNodeDownloadReleaseFileMode;

      
        _scanURL = _url ;

        [self startReleaseScan];
    }
}

- (NSString*)releaseFileTempPath
{
    NSString* releaseFileTempPath = _releaseFileTempPath;

    if (releaseFileTempPath == nil)
    {
        ATCydiaRepositoryNode* child = nil;

        for (child in _children)
        {
            NSString* childReleaseFileTempPath = [child releaseFileTempPath];
            if (childReleaseFileTempPath != nil)
                releaseFileTempPath = childReleaseFileTempPath;
        }
    }

    return releaseFileTempPath;
}

- (NSString*)packagesFileTempPath
{
    NSString* packagesFileTempPath = _packagesFileTempPath;

    if (packagesFileTempPath == nil)
    {
        ATCydiaRepositoryNode* child = nil;

        for (child in _children)
        {
            packagesFileTempPath = [child packagesFileTempPath];
            if (packagesFileTempPath != nil)
                break;
        }
    }

    return packagesFileTempPath;
}

#pragma mark -
#pragma mark *** ATURLDownloadDelegate interface ***
#pragma mark -

- (void)download:(ATURLDownload*)dl didCreateDestination:(NSString*)path
{
    
    _tempFileName = [path copy];
}

- (void)downloadDidFinish:(ATURLDownload*)download
{
    NSError* _error = nil;

    switch (_mode)
    {
        case ATCydiaRepositoryNodeDownloadStandardRelease :
        {
            if ([self checkPackagesReleaseFile:_tempFileName])
            {
                
                _releaseFileTempPath = [_tempFileName copy];

                
                _tempFileName = nil;

                _mode = ATCydiaRepositoryNodeDownloadStandardPackages;

               
                _scanURL = [[NSURL alloc] initWithString:[[_url absoluteString] stringByAppendingString:ATCydiaSourceStandardPackagesPath]];

                [self startNodePackagesScanWithExtension:nil];
            }
            else
                [self download:download didFailWithError:nil];

            break;
        }

        case ATCydiaRepositoryNodeDownloadPackagesMode :
        case ATCydiaRepositoryNodeDownloadStandardPackages :
        {
            if ([self checkPackagesReleaseFile:_tempFileName] && [self checkFolderName])
            {
                
                _packagesFileTempPath = [_tempFileName copy];

                NSString* fullName = _packagesFileTempPath;
                NSString* ext = [[[download.url absoluteString] lastPathComponent] pathExtension];
                if ([ext length] > 0)
                {
                    fullName = [_packagesFileTempPath stringByAppendingPathExtension:ext];
                    [[NSFileManager defaultManager] moveItemAtPath:_packagesFileTempPath toPath:fullName error:nil];
                }

                // XXX FIXME iPhoneOS has no NSTask, and the gunzip / bunzip2 is not guaranteed to be present, so think what can be done there...
#ifdef INSTALLER_APP
                if ([ext isEqualToString:@"gz"])
                {
                    NSTask* unzipTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/gunzip" arguments:[NSArray arrayWithObject:fullName]];
                    [unzipTask waitUntilExit];
                }
                else if ([ext isEqualToString:@"bz2"])
                {
                    NSTask* unzipBz2Task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/bunzip2" arguments:[NSArray arrayWithObject:fullName]];
                    [unzipBz2Task waitUntilExit];
                }
#endif // INSTALLER_APP

                _tempFileName = nil;

                if ([self shouldContinueScan])
                {
                    if (_mode == ATCydiaRepositoryNodeDownloadPackagesMode)
                    {
                        if (_parent == nil)
                        {
                            _mode = ATCydiaRepositoryNodeDownloadStandardRelease;

                            
                            _scanURL = [[NSURL alloc] initWithString:[[_url absoluteString] stringByAppendingString:ATCydiaSourceStandardReleasePath]];

                            [self startReleaseScan];
                        }
                        else
                            [self startNodeHTMLDownload];
                    }
                    else
                        [self startNodeHTMLDownload];
                }
                else
                    [self callScanDidFinish];
            }
            else
                [self download:download didFailWithError:nil];

            break;
        }

        case ATCydiaRepositoryNodeDownloadReleaseFileMode :
        {
            if ([self checkPackagesReleaseFile:_tempFileName])
            {
                
                _releaseFileTempPath = [_tempFileName copy];

                
                _tempFileName = nil;

                if ([self shouldContinueScan])
                {
                    _mode = ATCydiaRepositoryNodeDownloadPackagesMode;

                    [self startNodePackagesScanWithExtension:nil];
                }
                else
                    [self callScanDidFinish];
            }
            else
                [self download:download didFailWithError:nil];

            break;
        }

        case ATCydiaRepositoryNodeDownloadHTMLMode :
        default :
        {
            if (_nodeHTML == nil && _tempFileName != nil)
            {
                
                _nodeHTML = [[NSString alloc] initWithContentsOfFile:_tempFileName encoding:NSUTF8StringEncoding error:&_error];

                

                [[NSFileManager defaultManager] removeItemAtPath:_tempFileName error:nil];

                
                _tempFileName = nil;
            }

            if (_nodeHTML != nil && _error == nil)
                [self startChildrenScan];
            else
                [self callScanDidFinish];

            break;
        }
    }
}

- (void)download:(ATURLDownload*)download didFailWithError:(NSError*)error
{
    if (_tempFileName != nil)
    {
        [[NSFileManager defaultManager] removeItemAtPath:_tempFileName error:nil];

        
        _tempFileName = nil;
    }

    switch (_mode)
    {
        case ATCydiaRepositoryNodeDownloadStandardRelease :
        {
            _mode = ATCydiaRepositoryNodeDownloadStandardPackages;

            
            _scanURL = [[NSURL alloc] initWithString:[[_url absoluteString] stringByAppendingString:ATCydiaSourceStandardPackagesPath]];

            [self startNodePackagesScanWithExtension:nil];

            break;
        }

        case ATCydiaRepositoryNodeDownloadStandardPackages :
        {
            NSString* extension = [[[download.url absoluteString] lastPathComponent] pathExtension];
            if ([extension length] > 0)
                [self startNodePackagesScanWithExtension:extension];
            else
            {
                
                _scanURL = _url;

                [self startNodeHTMLDownload];
            }

            break;
        }

        case ATCydiaRepositoryNodeDownloadPackagesMode :
        {
            NSString* extension = [[[download.url absoluteString] lastPathComponent] pathExtension];
            if ([extension length] > 0)
                [self startNodePackagesScanWithExtension:extension];
            else
            {
                if (_parent == nil)
                {
                    _mode = ATCydiaRepositoryNodeDownloadStandardRelease;

                    
                    _scanURL = [[NSURL alloc] initWithString:[[_url absoluteString] stringByAppendingString:ATCydiaSourceStandardReleasePath]];

                    [self startReleaseScan];
                }
                else
                    [self startNodeHTMLDownload];
            }

            break;
        }

        case ATCydiaRepositoryNodeDownloadReleaseFileMode :
        {
            _mode = ATCydiaRepositoryNodeDownloadPackagesMode;

            [self startNodePackagesScanWithExtension:nil];

            break;
        }

        case ATCydiaRepositoryNodeDownloadHTMLMode :
        default :
        {
            [self callScanDidFinish];

            break;
        }
    }
}

#pragma mark -
#pragma mark *** Private interface ***
#pragma mark -

- (void)setParent:(ATCydiaRepositoryNode*)parent
{
    _parent = parent;
}

- (NSArray*)extensions
{
    if (sExtensions == nil)
    {
        NSString* extensionsFileName = [[NSBundle bundleForClass:[self class]] pathForResource:@"PackagesExtensions" ofType:@"plist"];

        if (extensionsFileName != nil)
            sExtensions = [[NSArray alloc] initWithContentsOfFile:extensionsFileName];
    }

    return sExtensions;
}

- (NSArray*)folderOrder
{
    if (sFolderOrder == nil)
    {
        NSString* orderFileName = [[NSBundle bundleForClass:[self class]] pathForResource:@"CydiaFolderOrder" ofType:@"plist"];

        if (orderFileName != nil)
            sFolderOrder = [[NSArray alloc] initWithContentsOfFile:orderFileName];
    }

    return sFolderOrder;
}

- (void)startNodePackagesScanWithExtension:(NSString*)ext
{
    NSString* fileName = nil;

    NSArray* extensions = [self extensions];
    if ([extensions count] > 0)
    {
        if (ext == nil)
            fileName = [ATCydiaSourcePackagesFileName stringByAppendingPathExtension:[extensions extraFirstObject]];
        else
        {
            NSUInteger extIndex = [extensions indexOfObject:ext];
            if (extIndex < ([extensions count] - 1))
                fileName = [ATCydiaSourcePackagesFileName stringByAppendingPathExtension:[extensions objectAtIndex:(extIndex + 1)]];
            else
                fileName = ATCydiaSourcePackagesFileName;
        }
    }

    if (fileName != nil)
    {
        NSURL* packageURL = [NSURL URLWithString:[[_scanURL absoluteString] stringByAppendingString:fileName]];

        if (_urlDownload.delegate == self)
            _urlDownload.delegate = nil;

        
        _urlDownload = [[ATURLDownload alloc] initWithRequest:[NSURLRequest requestWithURL:packageURL] delegate:self userAgent:ATCydiaUserAgent];
    }
}

- (void)startReleaseScan
{
    NSURL* releaseURL = [NSURL URLWithString:[[_scanURL absoluteString] stringByAppendingString:ATCydiaSourceReleaseFileName]];

    if (_urlDownload.delegate == self)
        _urlDownload.delegate = nil;

    
    _urlDownload = [[ATURLDownload alloc] initWithRequest:[NSURLRequest requestWithURL:releaseURL] delegate:self userAgent:ATCydiaUserAgent];
}

- (BOOL)shouldContinueScan
{
    if (_parent != nil)
        return [_parent shouldContinueScan];

    return ([self packagesFileTempPath] == nil);
}

- (void)startNodeHTMLDownload
{
    _mode = ATCydiaRepositoryNodeDownloadHTMLMode;

    if (_nodeHTML == nil)
    {
        if (_urlDownload.delegate == self)
            _urlDownload.delegate = nil;

        
        _urlDownload = [[ATURLDownload alloc] initWithRequest:[NSURLRequest requestWithURL:_url] delegate:self userAgent:ATCydiaUserAgent];
    }
    else
        [self downloadDidFinish:nil];
}

- (void)startChildrenScan
{
    _mode = ATCydiaRepositoryNodeScanChildrenMode;

    NSArray* folders = [_nodeHTML componentsSeparatedByString:@"href"];
    if ([folders count] > 1)
    {
        // Create children items.
        
        _children = nil;

        NSString* componentString = nil;

        for (componentString in folders)
        {
            NSRange findedBeginRange = [componentString rangeOfString:@">"];
            NSRange findedEndRange = [componentString rangeOfString:@"<"];

            if (findedBeginRange.location != NSNotFound && findedEndRange.location != NSNotFound && findedEndRange.location > findedBeginRange.location)
            {
                NSString* hyperLink = [componentString substringWithRange:NSMakeRange(findedBeginRange.location + 1, findedEndRange.location - findedBeginRange.location - 1)];
                if ([hyperLink hasSuffix:@"/"] && [hyperLink length] > 1 && ![hyperLink hasPrefix:@".."])
                {
                    NSString* nodePath = [[_url absoluteString] stringByAppendingString:hyperLink];

                    ATCydiaRepositoryNode* childNode = [[ATCydiaRepositoryNode alloc] initWithURL:[NSURL URLWithString:nodePath] nodeHTMLFilePath:nil];

                    if (childNode != nil)
                    {
                        if (_children == nil)
                            _children = [[NSMutableArray alloc] initWithCapacity:0];

                        [_children addObject:childNode];

                        [childNode setParent:self];

                        
                    }
                }
            }
        }
    }

    if ([_children count] > 0)
    {
        
        _scanChildren = [_children mutableCopy];
        [_scanChildren sortUsingSelector:@selector(compareNodes:)];

        ATCydiaRepositoryNode* node = [_scanChildren extraFirstObject];
        [node startScan];
        [_scanChildren removeObject:node];
    }
    else
        [self callScanDidFinish];
}

- (void)callScanDidFinish
{
    if (_parent != nil)
        [_parent scanDidFinishInNode:self];
    else
        [_delegate scanDidFinishInNode:self];
}

- (void)scanDidFinishInNode:(ATCydiaRepositoryNode*)node
{
    if ([_scanChildren count] > 0 && [self shouldContinueScan])
    {
        ATCydiaRepositoryNode* node = [_scanChildren extraFirstObject];
        [node startScan];
        [_scanChildren removeObject:node];
    }
    else
        [self callScanDidFinish];
}

- (BOOL)checkPackagesReleaseFile:(NSString*)filePath
{
    NSString* fileString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if (fileString == nil)
        fileString = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];

    return (fileString == nil || ([fileString length] > 0 && [fileString rangeOfString:@"<html" options:NSCaseInsensitiveSearch].location == NSNotFound));
}

- (NSComparisonResult)compareNodes:(ATCydiaRepositoryNode*)node
{
    NSString* nodeFolderName = [[[node->_url absoluteString] lastPathComponent] stringByDeletingPathExtension];
    NSString* selfFolderName = [[[_url absoluteString] lastPathComponent] stringByDeletingPathExtension];

    NSArray* cydiaOrder = [self folderOrder];
    NSUInteger nodeFolderNameIndex = [cydiaOrder indexOfObject:nodeFolderName];
    NSUInteger selfFolderNameIndex = [cydiaOrder indexOfObject:selfFolderName];

    if (nodeFolderNameIndex < selfFolderNameIndex)
        return NSOrderedDescending;
    else if (nodeFolderNameIndex > selfFolderNameIndex)
        return NSOrderedAscending;

    return NSOrderedSame;
}

- (BOOL)checkFolderName
{
    BOOL result = YES;

    NSString* folderName = [[[_url absoluteString] lastPathComponent] stringByDeletingPathExtension];

    if ([folderName hasPrefix:@"binary-"])
    {
        NSRange findedRange = [folderName rangeOfString:@"iphoneos-arm"];
        if (findedRange.location >= [folderName length])
            result = NO;
    }

    return result;
}

@end
