//
//  STGitWalker.m
//  StatsTool
//
//  Created by Deszip on 05.02.2022.
//

#import "STGitWalker.h"

@interface STGitWalker ()

@property (strong, nonatomic) NSURL *repoURL;
@property (strong, nonatomic) NSURL *workingDirURL;
@property (strong, nonatomic) STClocMetric *clocMetric;

@property (strong, nonatomic) NSURL *gitBinaryURL;

@end

@implementation STGitWalker

- (instancetype)initWithRepoURL:(NSURL *)repoURL workingDirectory:(NSURL *)workingDirURL clocMetric:(STClocMetric *)clocMetric {
    if (self = [super init]) {
        _repoURL = repoURL;
        _workingDirURL = workingDirURL;
        _clocMetric = clocMetric;
    }
    
    return self;;
}

- (BOOL)prepareEnv {
    __block BOOL gitFound = NO;
    NSArray *gitPaths = @[@"/usr/local/bin/git", @"/usr/bin/git"];
    [gitPaths enumerateObjectsUsingBlock:^(NSString *nextPath, NSUInteger idx, BOOL *stop) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:nextPath]) {
            self.gitBinaryURL = [NSURL fileURLWithPath:nextPath];
            gitFound = YES;
            *stop = YES;
        }
    }];
    
    BOOL workingDirectoryReady = NO;
    BOOL isDir = NO;
    BOOL workingDirectoryFound = [[NSFileManager defaultManager] fileExistsAtPath:self.workingDirURL.path isDirectory:&isDir];
    if (workingDirectoryFound) {
        NSError *cleanError;
        if (![[NSFileManager defaultManager] removeItemAtURL:self.workingDirURL error:&cleanError]) {
            NSLog(@"Failed to remove working directory at %@, %@", self.workingDirURL.path, cleanError);
        }
    }
    
    NSError *createError = nil;
    if ([[NSFileManager defaultManager] createDirectoryAtURL:self.workingDirURL withIntermediateDirectories:YES attributes:nil error:&createError]) {
        workingDirectoryReady = YES;
    }
    
    BOOL clocReady = [self.clocMetric prepareEnv];
    
    NSLog(@"Checking git....................[%@]", gitFound ? @"OK" : @"FAIL");
    NSLog(@"Checking working directory......[%@]", workingDirectoryReady ? @"OK" : @"FAIL");
    NSLog(@"Checking cloc metric............[%@]", clocReady ? @"OK" : @"FAIL");
    
    return gitFound && workingDirectoryReady && clocReady;
}

- (void)cloneRepo {
    NSTask *cloneTask = [NSTask new];
    cloneTask.executableURL = self.gitBinaryURL;
    cloneTask.arguments = @[@"clone", self.repoURL.path, self.workingDirURL.path];
    [cloneTask launch];
    [cloneTask waitUntilExit];
}

- (NSUInteger)commitsCount {
    NSTask *countTask = [NSTask new];
    countTask.currentDirectoryPath = self.workingDirURL.path;
    countTask.executableURL = self.gitBinaryURL;
    countTask.arguments = @[@"rev-list", @"HEAD", @"--count"];
    
    NSPipe *countPipe = [NSPipe pipe];
    [countTask setStandardOutput:countPipe];
    [countTask launch];
    [countTask waitUntilExit];
    
    NSFileHandle *readCommitCount = [countPipe fileHandleForReading];
    NSString *commitsCount = [[NSString alloc] initWithData:[readCommitCount readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    
    return commitsCount.integerValue;
}

- (void)goBack {
    NSTask *revertTask = [NSTask new];
    [revertTask setStandardOutput:[NSPipe pipe]];
    revertTask.currentDirectoryPath = self.workingDirURL.path;
    revertTask.executableURL = self.gitBinaryURL;
    revertTask.arguments = @[@"reset", @"--hard", @"HEAD~1"];
    [revertTask setTerminationHandler:^(NSTask *task){
        if ([task terminationStatus] != EXIT_SUCCESS) {
            NSLog(@"Revert failed...");
        }
    }];
    [revertTask launch];
    [revertTask waitUntilExit];
}

- (NSURL *)writeStats {
    // Get current commit hash
    // git rev-parse HEAD
    NSTask *hashTask = [NSTask new];
    hashTask.currentDirectoryPath = self.workingDirURL.path;
    hashTask.executableURL = self.gitBinaryURL;
    hashTask.arguments = @[@"rev-parse", @"HEAD"];
    
    NSPipe *hashPipe = [NSPipe pipe];
    [hashTask setStandardOutput:hashPipe];
    [hashTask launch];
    [hashTask waitUntilExit];
    
    NSFileHandle *readCommithash = [hashPipe fileHandleForReading];
    NSString *currentHash = [[[NSString alloc] initWithData:[readCommithash readDataToEndOfFile] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [self.clocMetric apply:currentHash];
}

- (void)startProcessing {
    // Get repo
    [self cloneRepo];
            
    // Parameters
    NSUInteger depth = [self commitsCount];
    NSLog(@"Got %lu commits", (unsigned long)depth);
    
    NSTimeInterval totalStepTime = 0;
    NSTimeInterval averageStepTime = 0;
    
    // Write stats
    __block NSMutableArray <NSURL *> *statsResults = [@[] mutableCopy];
    for (NSUInteger i = 0; i < depth; i++) {
        NSLog(@"Getitng stats for commit %lu", depth - i);
        
        NSDate *startDate = [NSDate date];

        [statsResults addObject:[self writeStats]];
        
        NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:startDate];
        totalStepTime += elapsed;
        averageStepTime = totalStepTime / (i + 1);
        NSLog(@"Finished step %lu in %f, average: %f, total: %f", (unsigned long)i, elapsed, averageStepTime, totalStepTime);
        
        if (i > 0) {
            [self goBack];
        }
    }

    NSLog(@"Total time: %f", totalStepTime);
    NSLog(@"Total time: %f", averageStepTime);
    NSLog(@"Saved %lu results at: %@", (unsigned long)statsResults.count, self.clocMetric.outputDirectoryURL);
}

@end
