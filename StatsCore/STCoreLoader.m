//
//  STCoreLoader.m
//  StatsCore
//
//  Created by Deszip on 22.03.2024.
//

#import "STCoreLoaderPrivate.h"

static NSString * const kSTGroupID = @"group.com.stats";

@interface STCoreLoader ()

@end

@implementation STCoreLoader

+ (instancetype)defaultLoader {
    static STCoreLoader *defaultLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultLoader = [STCoreLoader new];
    });

    return defaultLoader;
}

- (instancetype)init {
    if (self = [super init]) {
        //...
    }

    return self;
}



@end
