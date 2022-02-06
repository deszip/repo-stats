//
//  STClocMetric.h
//  StatsTool
//
//  Created by Deszip on 06.02.2022.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STClocMetric : NSObject

@property (strong, nonatomic, readonly) NSURL *workingDirectoryURL;
@property (strong, nonatomic, readonly) NSURL *outputDirectoryURL;
@property (assign, nonatomic, readonly) BOOL continuationEnabled;

- (instancetype)initWithWorkingDirectory:(NSURL *)workingDirectory
                         outputDirectory:(NSURL *)outputDirectory
                     supportContinuation:(BOOL)continuationEnabled;

- (BOOL)prepareEnv;
- (NSURL *)apply:(NSString *)commitHash;

@end

NS_ASSUME_NONNULL_END
