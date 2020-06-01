//
//  ATLuaScript.h
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "lua.h"

@class ATScript;

@interface ATLuaScript : NSObject {

	__unsafe_unretained ATScript*		script;

	@private
		lua_State*		mLua;
}

@property (nonatomic, assign) ATScript* script;

- (BOOL)runScript:(NSString*)filename error:(NSString**)error;
- (BOOL)runScriptData:(NSData*)data error:(NSString**)error;

@end
