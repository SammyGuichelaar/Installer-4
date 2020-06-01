//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/NSObject.h>

/*********        forward declarations, globals and typedefs        *********/

@class ATURLDownload;
@protocol ATCydiaRepositoryNodeDelegate;

typedef enum
{
    ATCydiaRepositoryNodeNotScanMode = 0,
    ATCydiaRepositoryNodeDownloadStandardRelease,
    ATCydiaRepositoryNodeDownloadStandardPackages,
    ATCydiaRepositoryNodeDownloadPackagesMode,
    ATCydiaRepositoryNodeDownloadReleaseFileMode,
    ATCydiaRepositoryNodeDownloadHTMLMode,
    ATCydiaRepositoryNodeScanChildrenMode
}
ATCydiaRepositoryNodeMode;

/*********        interface for ATCydiaRepositoryNode        *********/
/*!
    @class ATCydiaRepositoryNode
    @discussion Interface for Cydia repository node.
*/

@interface ATCydiaRepositoryNode : NSObject
{
@private
    ATCydiaRepositoryNode* _parent; // Not retained.
    NSURL* _url;
    ATURLDownload* _urlDownload;

    NSString* _releaseFileTempPath;
    NSString* _packagesFileTempPath;
    NSString* _tempFileName;

    NSMutableArray* _children;
    NSMutableArray* _scanChildren;

    NSString* _nodeHTML;
 
   
    ATCydiaRepositoryNodeMode _mode;
    NSURL* _scanURL;
}

@property (nonatomic, readwrite, assign) id<ATCydiaRepositoryNodeDelegate> _delegate;

@property (nonatomic, readonly, retain) NSURL* _url;

- (id)initWithURL:(NSURL*)url nodeHTMLFilePath:(NSString*)nodeHTMLPath;

- (void)startScan;

- (NSString*)releaseFileTempPath;

- (NSString*)packagesFileTempPath;

@end

#pragma mark -

@protocol ATCydiaRepositoryNodeDelegate

- (void)scanDidFinishInNode:(ATCydiaRepositoryNode*)node;

@end
