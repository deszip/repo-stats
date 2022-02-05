//
//  STGitWalker.h
//  StatsTool
//
//  Created by Deszip on 05.02.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STGitWalker : NSObject

- (instancetype)initWithRepoURL:(NSURL *)repoURL workingDirectory:(NSURL *)workingDirURL;

- (BOOL)prepareEnv;
- (void)startProcessing;

@end

NS_ASSUME_NONNULL_END
