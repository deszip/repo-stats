//
//  STRepoStorage.h
//  StatsCore
//
//  Created by Deszip on 22.03.2024.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface STRepoStorage : NSObject

- (void)addRepo:(NSString *)name path:(NSString *)path;
- (void)removeRepo:(NSUUID *)repoID;

@end

NS_ASSUME_NONNULL_END
