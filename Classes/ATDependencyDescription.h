//
//  ATDependencyDescription.h
//  Installer
//
//  Created by Slava Karpenko on 23/02/2018.
//  Copyright © 2018 Slava Karpenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATDependencyDescription : NSObject
@property (nonatomic, nonnull, strong) NSString* identifier;
@property (nonatomic, nullable, strong) NSString* version;
@property (nonatomic, nullable, strong) NSString* operation;      // Operator suitable for passing into -[NSString compareWithVersion:operation:]
@property (nonatomic, nullable, strong) NSString* repoURLString;

+ (ATDependencyDescription* _Nonnull)dependencyDescriptionWithIdentifier:(NSString* _Nonnull)identifier version:(NSString* _Nullable)version operation:(NSString* _Nullable)operation repoURLString:(NSString* _Nullable)repoURLString;
- (ATDependencyDescription* _Nonnull)initWithIdentifier:(NSString* _Nonnull)identifier version:(NSString* _Nullable)version operation:(NSString* _Nullable)operation repoURLString:(NSString* _Nullable)repoURLString;
@end
