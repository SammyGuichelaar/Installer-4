//
//  ATDependencyDescription.m
//  Installer
//
//  Created by Slava Karpenko on 23/02/2018.
//  Copyright © 2018 Slava Karpenko. All rights reserved.
//

#import "ATDependencyDescription.h"

@implementation ATDependencyDescription
+ (ATDependencyDescription*)dependencyDescriptionWithIdentifier:(NSString*)identifier version:(NSString*)version operation:(NSString*)operation repoURLString:(NSString*)repoURLString
{
    return [[ATDependencyDescription alloc] initWithIdentifier:identifier version:version operation:operation repoURLString:repoURLString];
}

- (ATDependencyDescription*)initWithIdentifier:(NSString*)identifier version:(NSString*)version operation:(NSString*)operation repoURLString:(NSString*)repoURLString
{
    if (self = [super init]) {
        self.identifier = identifier;
        self.version = version;
        self.operation = operation;
        self.repoURLString = repoURLString;
    }
    
    return self;
}
@end
