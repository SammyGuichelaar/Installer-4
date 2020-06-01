/*
 *  Scythe.c
 *  Installer
 *
 *  Copyright 2017-2018 Infini Development bV(Sam Guicheelar & Christian Tabuyo). All rights reserved.
 *
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char * argv[])
{
	char fullpath[1024];
	
	strncpy(fullpath, argv[0], strlen(argv[0]) - strlen("Scythe"));
	strcat(fullpath, "Installer");
	
	char* newArgv[] = { fullpath, NULL };
	
	return execve(fullpath, newArgv, NULL);
}
