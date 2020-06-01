// AppTapp Framework
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import "NSFileManager+AppTappExtensions.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSFileManager (AppTappExtensions)

- (NSString *)fileHashAtPath:(NSString *)aPath {
	FILE * file;
	size_t bytes;
	unsigned char buffer[1024];

	// Get the file
	if((file = fopen([aPath fileSystemRepresentation], "rb"))) {
		CC_MD5_CTX ctx;
		unsigned char digest[16];

		CC_MD5_Init(&ctx);

		while((bytes = fread(buffer, 1, sizeof(buffer), file)) > 0) {
			CC_MD5_Update(&ctx, buffer, (CC_LONG)bytes);
		}

		CC_MD5_Final(digest, &ctx);
		fclose(file);
	
		char hexdigest[33];
		int a;

		for (a = 0; a < 16; a++) sprintf(hexdigest + 2*a, "%02x", digest[a]);

		return [NSString stringWithUTF8String:hexdigest];
	} else {
		return nil;
	}
}

- (BOOL)createPath:(NSString *)aPath handler:(id)handler {
	BOOL isDirectory = NO;
	if([self fileExistsAtPath:aPath isDirectory:&isDirectory] && isDirectory) return YES; // Save time

	NSEnumerator		*   allFolders  = [[aPath pathComponents] objectEnumerator];
	NSString		*   folderPath  = @"/"; // This forces path to always start at /, why wouldn't it?
	NSString		*   folder;
	
	while(folder = [allFolders nextObject]) {
		folderPath = [folderPath stringByAppendingPathComponent:folder];
		if(![self fileExistsAtPath:folderPath isDirectory:&isDirectory]) {
			NSDictionary * attributes = nil;

//			if(handler != nil) attributes = [handler performSelector:@selector(fileManager:createAttributesAtPath:) withObject:self withObject:folderPath];
			// SKA - attributesAtPath were returning attributes for the last selected fileInfo, which is a single file and has incorrect permissions for a directory (for instance, missing +x bit)
			NSNumber* posixPerms = [NSNumber numberWithLong:(0000755)];

			attributes = [NSDictionary dictionaryWithObjectsAndKeys:
							posixPerms,	NSFilePosixPermissions,
							@"root", NSFileOwnerAccountName,
							@"wheel", NSFileGroupOwnerAccountName,
							nil];
			
			if(![self createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:attributes error:nil]) return NO;
		} if(!isDirectory) {
			return NO;
		}
	}

	return YES;
}

// Works like ditto, not NSFileManager!!! Should really be called something else and might contain bugs, too
- (BOOL)copyPath:(NSString *)source toPath:(NSString *)destination handler:(id)handler {
	BOOL result = YES;
	BOOL isDirectory = NO;

	// this is new, hope its not buggy? TESTME
	NSString * destinationPath = [destination stringByDeletingLastPathComponent];
	if(![self fileExistsAtPath:destination]) { // Create the folder?
		if(![self createPath:destinationPath handler:nil]) return NO;
	}

	if([self fileExistsAtPath:source isDirectory:&isDirectory]) {
		NSDictionary * attributes = [self attributesOfItemAtPath:source error:nil];

		if(isDirectory) {
			[self createDirectoryAtPath:destination withIntermediateDirectories:YES attributes:attributes error:nil];

			NSEnumerator * subpaths = [[self subpathsAtPath:source] objectEnumerator];
			NSString * subpath;

			while((subpath = [subpaths nextObject])) {
				NSString * sourcePath = [source stringByAppendingPathComponent:subpath];
				NSString * destinationPath = [destination stringByAppendingPathComponent:subpath];

				if([self fileExistsAtPath:sourcePath isDirectory:&isDirectory]) {
					attributes = [self attributesOfItemAtPath:sourcePath error:nil];
					if(isDirectory) { // Directory
						result = [self createDirectoryAtPath:destination withIntermediateDirectories:YES attributes:attributes error:nil];
					} else { // File
                        NSError* err = nil;
						NSData * contents = [NSData dataWithContentsOfFile:sourcePath options:NSDataReadingMappedIfSafe error:&err ];
						result = [self createFileAtPath:destinationPath contents:contents attributes:attributes];
					}
				}

				if(!result) {
					Log(@"Error copying path: %@ to path: %@", sourcePath, destinationPath);
					break;
				}
			}
		} else {
            NSError* err = nil;
            NSData* contents = [NSData dataWithContentsOfFile:source options:NSDataReadingMappedIfSafe error:&err];
			result = [self createFileAtPath:destination contents:contents attributes:attributes];
		}
	}

	return result;
}


- (NSNumber *)freeSpaceAtPath:(NSString *)aPath {
        NSDictionary * fsAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:aPath error:nil];
        return [fsAttributes objectForKey:NSFileSystemFreeSize];
}

- (NSString*)tempFilePath
{

	char* filename =tempnam([self fileSystemRepresentationWithPath:NSTemporaryDirectory()], "Installer-");

	if (filename)
	{
		NSString* filePath = [self stringWithFileSystemRepresentation:filename length:strlen(filename)];
		
		free(filename);
		
		return filePath;
	}
	
	return nil;
}

@end
