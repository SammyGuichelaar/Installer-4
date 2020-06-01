//
//  ATError.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>

/* Various errors returned from the AppTapp framework */
#define AppTappErrorDomain @"com.apptapp.installer"

typedef enum {
	kATErrorDependencyNotFound			= 1,					// [userInfo objectForKey:@"packageID"] = failed depenedency ID
	kATErrorPackageInfoDecodeFailed		= 2,					// [userInfo objectForKey:@"packageID"] = failed package ID
	kATErrorPackageHashInvalid			= 3,					// [userInfo objectForKey:@"package"] = failed ATPackage*, [userInfo objectForKey:@"task"] = failed ATTask*
	kATErrorPackageFileSizeInvalid		= 4,					// [userInfo objectForKey:@"package"] = failed ATPackage*, [userInfo objectForKey:@"task"] = failed ATTask*
	kATErrorScriptError					= 5,					// [userInfo objectForKey:@"package"] = failed ATPackage*, [userInfo objectForKey:@"task"] = failed ATTask*, [userInfo objectForKey:@"script"] = failed NSArray* with script
	kATErrorPackageNotInstalled			= 6,					// [userInfo objectForKey:@"package"] = failed ATPackage*
	kATErrorTrustedSourcesRefreshFailed = 7,					// 
	kATErrorPackageNotFound				= 8,					// [userInfo objectForKey:@"packageID"] = failed package ID
	kATErrorJailbreakRequired			= 9,					// [userInfo objectForKey:@"package"] = failed ATPackage*, [userInfo objectForKey:@"task"] = failed ATTask*
	kATErrorPackageNotUninstalled		= 10,					// [userInfo objectForKey:@"package"] = failed ATPackage*
    kATErrorPhoneRegistration           = 11,
    kATErrorPackageInvalidLocation      = 12,
    kATErrorInstallationPackage         = 13,
    kATErrorBackupDevice                = 14,
    kATErrorRestoreDevice               = 15,
    kATErrorSynchronization             = 16,
    kATErrorDependencyInvalidVersion    = 17,                   // [userInfo objectForKey:@"packageID"] = failed depenedency ID
    kATErrorRepositoryAddedRefreshing   = 18
} ATErrorValue;

