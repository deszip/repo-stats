//
//  STGitToolkit.h
//  StatsCore
//
//  Created by Deszip on 03.04.2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STGitToolkit : NSObject

- (instancetype)initWithWorkingDIrectory:(NSURL *)workingDirectory;

- (void)cloneRepo:(NSString *)repoPath branch:(NSString *)branch;
- (NSUInteger)commitsCount;
- (BOOL)goBack;
- (NSString *)getStats;

@end

NS_ASSUME_NONNULL_END
