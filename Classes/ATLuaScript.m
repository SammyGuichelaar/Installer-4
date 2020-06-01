//
//  ATLuaScript.m
//  Installer
//
//  Copyright 2017-2018 Infinidev BV i.o(Sam Guicheelar & Christian Tabuyo). All rights reserved.
//

#define LUA_LIB
#import "lua.h"
#import "lauxlib.h"
#import "lualib.h"
#import "ATLuaScript.h"
#import "ATScript.h"
#import "ATPlatform.h"

static int lua_CopyPath(lua_State *L);
static int lua_MovePath(lua_State *L);
static int lua_LinkPath(lua_State *L);
static int lua_RemovePath(lua_State *L);
static int lua_Notice(lua_State *L);
static int lua_SetStatus(lua_State *L);
static int lua_Confirm(lua_State *L);
static int lua_AbortOperation(lua_State *L);
static int lua_ExistsPath(lua_State *L);
static int lua_IsLink(lua_State *L);
static int lua_IsFolder(lua_State *L);
static int lua_IsFile(lua_State *L);
static int lua_IsExecutable(lua_State *L);
static int lua_IsWritable(lua_State *L);
static int lua_InstalledPackage(lua_State *L);
static int lua_ChangeMode(lua_State *L);
static int lua_ChangeModeRecursive(lua_State *L);
static int lua_ChangeOwner(lua_State *L);
static int lua_ChangeOwnerGroup(lua_State *L);
static int lua_AddSource(lua_State *L);
static int lua_RemoveSource(lua_State *L);
static int lua_PlatformName(lua_State *L);
static int lua_FirmwareVersion(lua_State *L);
static int lua_FirmwareVersionAsNumber(lua_State *L);
static int lua_VersionStringAsNumber(lua_State *L);
static int lua_FirmwareVersionIsNewer(lua_State *L);
static int lua_FirmwareVersionIsOlder(lua_State *L);
static int lua_TempFileName(lua_State *L);
static int lua_DeviceUUID(lua_State *L);
static int lua_DeviceRootLocked(lua_State *L);
static int lua_RestartSpringBoard(lua_State *L);

static const luaL_Reg installLibIndex[] = {
	{	"CopyPath",			lua_CopyPath		},
	{	"MovePath",			lua_MovePath		},
	{	"LinkPath",			lua_LinkPath		},
	{	"RemovePath",		lua_RemovePath		},
	{	"Notice",			lua_Notice			},
	{	"SetStatus",		lua_SetStatus		},
	{	"Confirm",			lua_Confirm			},
	{	"AbortOperation",	lua_AbortOperation	},
	{	"ExistsPath",		lua_ExistsPath		},
	{	"PathExists",		lua_ExistsPath		},
	{	"IsLink",			lua_IsLink			},
	{	"IsFolder",			lua_IsFolder		},
	{	"IsFile",			lua_IsFile			},
	{	"IsExecutable",		lua_IsExecutable	},
	{	"IsWritable",		lua_IsWritable		},
	{	"InstalledPackage",	lua_InstalledPackage},
	{	"PackageInstalled",	lua_InstalledPackage},
	{	"ChangeMode",		lua_ChangeMode		},
	{	"ChangeModeRecursive",lua_ChangeModeRecursive			},
	{	"ChangeOwner",		lua_ChangeOwner		},
	{	"ChangeOwnerGroup",	lua_ChangeOwnerGroup},
	{	"AddSource",		lua_AddSource		},
	{	"RemoveSource",		lua_RemoveSource	},
	{	"PlatformName",		lua_PlatformName	},
	{	"FirmwareVersion",	lua_FirmwareVersion	},
	{	"FirmwareVersionAsNumber",	lua_FirmwareVersionAsNumber	},
	{	"FirmwareVersionIsNewer",	lua_FirmwareVersionIsNewer	},
	{	"FirmwareVersionIsOlder",	lua_FirmwareVersionIsOlder	},
	{	"VersionStringAsNumber",	lua_VersionStringAsNumber	},
	{	"TempFileName",		lua_TempFileName	},
	{	"DeviceUUID",		lua_DeviceUUID		},
	{	"DeviceRootLocked",	lua_DeviceRootLocked },
	{	"RestartSpringBoard",		lua_RestartSpringBoard	},
	//{	"FetchURL",			lua_FetchURL		},
	
	{	NULL,				NULL				}
};


@implementation ATLuaScript
@synthesize script;

- (ATLuaScript*)init
{
	if (self = [super init])
	{
		mLua = luaL_newstate();
        luaL_newlibtable(mLua, installLibIndex);
        luaL_setfuncs(mLua, installLibIndex, 0);
	}
	
	return self;
}

- (void)dealloc
{
	if (mLua)
    {
		lua_close(mLua);
    }
    [super dealloc];
}

- (BOOL)runScript:(NSString*)filename error:(NSString**)error
{
	return [self runScriptData:[NSData dataWithContentsOfFile:filename options:NSMappedRead error:nil] error:error];
}

- (BOOL)runScriptData:(NSData*)data error:(NSString**)error
{
	int res;
	
	lua_gc(mLua, LUA_GCRESTART, 0);
	res = luaL_loadbuffer(mLua, [data bytes], [data length], "script");
	if (res != 0)
	{
		if (error)
			*error = [NSString stringWithFormat:@"Can't load script: %@", [NSString stringWithCString:lua_tostring(mLua, -1) encoding:NSUTF8StringEncoding]];
		return NO;
	}
	
	// prepare a reference to our script
	lua_pushinteger(mLua, (lua_Integer)self.script);
	lua_setglobal(mLua, "___script");
	
	//NSAutoreleasePool* innerPool = [[NSAutoreleasePool alloc] init];
	res = lua_pcall(mLua, 0, LUA_MULTRET, 0);
	
	
	lua_gc(mLua, LUA_GCCOLLECT, 0);
	
    if (res)
	{
        Log(@"Failed to run script: %s\n", lua_tostring(mLua, -1));
		if (error)
			*error = [NSString stringWithCString:lua_tostring(mLua, -1) encoding:NSUTF8StringEncoding];
        return NO;
    }
	
	// get the result
	if (!lua_isboolean(mLua, -1) || !lua_toboolean(mLua, -1))
	{
		if (error && lua_isstring(mLua, -1))
			*error = [NSString stringWithCString:lua_tostring(mLua, -1) encoding:NSUTF8StringEncoding];
			
		res = 1;
	}

    lua_pop(mLua, 1);  /* Take the returned value out of the stack */
	
	lua_gc(mLua, LUA_GCCOLLECT, 0);
	
	return !res;
}

@end

#pragma mark -

ATScript* lua_i_GetScriptObject(lua_State* L)
{
    
	lua_getglobal(L, "___script");
	
    ATScript* script = (ATScript *)lua_tointeger(L, -1);
	
	lua_pop(L, 1);
	
	return script;
}

static int lua_CopyPath(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* path1 = luaL_checkstring(L, 1);
	const char* path2 = luaL_checkstring(L, 2);
	
	luaL_argcheck(L, path1 != NULL, 1, "source path is expected");
	luaL_argcheck(L, path2 != NULL, 2, "target path is expected");
	
	NSString* p1 = [NSString stringWithCString:path1 encoding:NSUTF8StringEncoding];
	NSString* p2 = [NSString stringWithCString:path2 encoding:NSUTF8StringEncoding];
	
	int result = [script script_CopyPath:[NSArray arrayWithObjects:p1, p2, nil]];
	
	lua_pushboolean(L, result);
	
	return 1;
}

static int lua_MovePath(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* path1 = luaL_checkstring(L, 1);
	const char* path2 = luaL_checkstring(L, 2);
	
	NSString* p1 = [NSString stringWithCString:path1 encoding:NSUTF8StringEncoding];
	NSString* p2 = [NSString stringWithCString:path2 encoding:NSUTF8StringEncoding];
	
	int result = [script script_MovePath:[NSArray arrayWithObjects:p1, p2, nil]];
	
	lua_pushboolean(L, result);
	
	return 1;
}

static int lua_LinkPath(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* path1 = luaL_checkstring(L, 1);
	const char* path2 = luaL_checkstring(L, 2);
	
	NSString* p1 = [NSString stringWithCString:path1 encoding:NSUTF8StringEncoding];
	NSString* p2 = [NSString stringWithCString:path2 encoding:NSUTF8StringEncoding];
	
	int result = [script script_LinkPath:[NSArray arrayWithObjects:p1, p2, nil]];
	
	lua_pushboolean(L, result);
	
	return 1;
}

static int lua_RemovePath(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* path = luaL_checkstring(L, 1);
	
	NSString* p = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
	
	int result = [script script_RemovePath:[NSArray arrayWithObject:p]];
	
	lua_pushboolean(L, result);
	
	return 1;
}

static int lua_Notice(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	
	int result = [script script_Notice:[NSArray arrayWithObject: t]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_SetStatus(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	
	int result = [script script_SetStatus:[NSArray arrayWithObject: t]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_Confirm(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	const char* button1 = luaL_checkstring(L, 2);
	const char* button2 = luaL_checkstring(L, 3);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	NSString* b1 = [NSString stringWithCString:button1 encoding:NSUTF8StringEncoding];
	NSString* b2 = [NSString stringWithCString:button2 encoding:NSUTF8StringEncoding];
	
	int result = [script script_Confirm:[NSArray arrayWithObjects: t, b1, b2, nil]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_AbortOperation(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	
	int result = [script script_AbortOperation:[NSArray arrayWithObject: t]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_ExistsPath(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	
	int result = [script script_ExistsPath:[NSArray arrayWithObject: t]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_IsLink(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	
	int result = [script script_IsLink:[NSArray arrayWithObject: t]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_IsFolder(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	
	int result = [script script_IsFolder:[NSArray arrayWithObject: t]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_IsFile(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	
	int result = [script script_IsFile:[NSArray arrayWithObject: t]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_IsExecutable(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	
	int result = [script script_IsExecutable:[NSArray arrayWithObject: t]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_IsWritable(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	
	int result = [script script_IsWritable:[NSArray arrayWithObject: t]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_InstalledPackage(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	
	int result = [script script_InstalledPackage:[NSArray arrayWithObject: t]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_ChangeMode(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* path = luaL_checkstring(L, 1);
	const char* mode = luaL_checkstring(L, 2);
	
	NSString* p = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
	NSString* m = [NSString stringWithCString:mode encoding:NSUTF8StringEncoding];
	
	int result = [script script_ChangeMode:[NSArray arrayWithObjects:p, m, nil]];
	
	lua_pushboolean(L, result);
	
	return 1;
}

static int lua_ChangeModeRecursive(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* path = luaL_checkstring(L, 1);
	const char* mode = luaL_checkstring(L, 2);
	
	NSString* p = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
	NSString* m = [NSString stringWithCString:mode encoding:NSUTF8StringEncoding];
	
	int result = [script script_ChangeModeRecursive:[NSArray arrayWithObjects:p, m, nil]];
	
	lua_pushboolean(L, result);
	
	return 1;
}

static int lua_ChangeOwner(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* path = luaL_checkstring(L, 1);
	const char* owner = luaL_checkstring(L, 2);
	
	NSString* p = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
	NSString* o = [NSString stringWithCString:owner encoding:NSUTF8StringEncoding];
	
	int result = [script script_ChangeOwner:[NSArray arrayWithObjects:p, o, nil]];
	
	lua_pushboolean(L, result);
	
	return 1;
}

static int lua_ChangeOwnerGroup(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* path = luaL_checkstring(L, 1);
	const char* owner = luaL_checkstring(L, 2);
	const char* group = luaL_checkstring(L, 3);
	
	NSString* p = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
	NSString* o = [NSString stringWithCString:owner encoding:NSUTF8StringEncoding];
	NSString* g = [NSString stringWithCString:group encoding:NSUTF8StringEncoding];;
	
	int result = [script script_ChangeOwner:[NSArray arrayWithObjects:p, o, g, nil]];
	
	lua_pushboolean(L, result);
	
	return 1;
}

static int lua_AddSource(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	
	int result = [script script_AddSource:[NSArray arrayWithObject: t]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_RemoveSource(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	const char* text = luaL_checkstring(L, 1);
	
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
	
	int result = [script script_RemoveSource:[NSArray arrayWithObject: t]];
	
	lua_pushboolean(L, result);
	return 1;
}

static int lua_PlatformName(lua_State* L)
{	
	lua_pushstring(L, [[ATPlatform platformName] cStringUsingEncoding:NSUTF8StringEncoding]);
	return 1;
}

static int lua_FirmwareVersion(lua_State* L)
{	
	lua_pushstring(L, [[ATPlatform firmwareVersion] cStringUsingEncoding:NSUTF8StringEncoding]);
	return 1;
}

static int lua_FirmwareVersionAsNumber(lua_State* L)
{
	unsigned long long versionNumber = [[ATPlatform firmwareVersion] versionNumber];
	double doubleVN = (double)versionNumber;
	
	lua_pushnumber(L, doubleVN);
	
	return 1;
}

static int lua_VersionStringAsNumber(lua_State* L)
{
	const char* text = luaL_checkstring(L, 1);
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];

	unsigned long long versionNumber = [t versionNumber];
	double doubleVN = (double)versionNumber;
	
	lua_pushnumber(L, doubleVN);
	
	return 1;
}

static int lua_FirmwareVersionIsNewer(lua_State* L)
{
	const char* text = luaL_checkstring(L, 1);
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];

	unsigned long long versionNumber = [t versionNumber];
	unsigned long long thisFirmwareVersion = [[ATPlatform firmwareVersion] versionNumber];
	
	lua_pushboolean(L, (versionNumber <= thisFirmwareVersion) ? 1 : 0);
	return 1;
}

static int lua_FirmwareVersionIsOlder(lua_State* L)
{
	const char* text = luaL_checkstring(L, 1);
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];

	unsigned long long versionNumber = [t versionNumber];
	unsigned long long thisFirmwareVersion = [[ATPlatform firmwareVersion] versionNumber];
	
	lua_pushboolean(L, (versionNumber > thisFirmwareVersion) ? 1 : 0);
	return 1;
}

static int lua_TempFileName(lua_State *L)
{
	NSString* tempFileName = [[NSFileManager defaultManager] tempFilePath];
	
	lua_pushstring(L, [[NSFileManager defaultManager] fileSystemRepresentationWithPath:tempFileName]);
	
	return 1;
}

static int lua_DeviceUUID(lua_State *L)
{
	NSString* uuid = [ATPlatform deviceUUID];
	
	lua_pushstring(L, [uuid cStringUsingEncoding:NSUTF8StringEncoding]);
	
	return 1;
}

static int lua_DeviceRootLocked(lua_State* L)
{	
	lua_pushboolean(L, [ATPlatform isDeviceRootLocked]);
	return 1;
}

static int lua_RestartSpringBoard(lua_State* L)
{
	ATScript* script = lua_i_GetScriptObject(L);
	
	[script script_RestartSpringBoard:[NSArray array]];
	
	lua_pushboolean(L, 1);
	
	return 1;
}


static int lua_FetchURL(lua_State* L)
{
	const char* text = luaL_checkstring(L, 1);
	NSString* t = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];

	unsigned long long versionNumber = [t versionNumber];
	unsigned long long thisFirmwareVersion = [[ATPlatform firmwareVersion] versionNumber];
	
	lua_pushboolean(L, (versionNumber >= thisFirmwareVersion) ? 1 : 0);
	return 1;
}

//Get rid of the unused function warning
void lua_nothing()
{
    lua_FetchURL(NULL);
}
