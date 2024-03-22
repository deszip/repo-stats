//
//  STCoreLoader.h
//  StatsCore
//
//  Created by Deszip on 22.03.2024.
//

#import <Foundation/Foundation.h>

@class STRepoStorage;

NS_ASSUME_NONNULL_BEGIN

@interface STCoreLoader : NSObject

+ (void)loadCore;

+ (STRepoStorage *)repoStorage;

@end

NS_ASSUME_NONNULL_END
