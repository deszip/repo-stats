//
//  STGitToolkit.h
//  StatsCore
//
//  Created by Deszip on 03.04.2024.
//

#import <Foundation/Foundation.h>

#import <StatsCore/STCommit.h>

NS_ASSUME_NONNULL_BEGIN

@interface STGitToolkit : NSObject

- (instancetype)initWithWorkingDirectory:(NSURL *)workingDirectory;

- (void)cloneRepo:(NSString *)repoPath branch:(NSString *)branch;
- (NSUInteger)commitsCount;
- (BOOL)goBack;
- (STCommit *)getStats:(NSString *)commitHash;

- (NSArray <NSString *> *)listCommits;

@end

NS_ASSUME_NONNULL_END
