//
//  main.m
//  StatsTool
//
//  Created by Deszip on 21.02.2021.
//

#import <Foundation/Foundation.h>

#import "STGitWalker.h"

//bool checkEnv(void) {
//    BOOL gitFound = [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/local/bin/git"];
//    BOOL clocFound = [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/local/bin/cloc"];
//
//    return gitFound && clocFound;
//}

//void cloneRepo(NSString *repoPath, NSString *workingDirectoryPath) {
//    NSTask *cloneTask = [NSTask new];
//    cloneTask.launchPath = @"/usr/local/bin/git";
//    cloneTask.arguments = @[@"clone", repoPath, workingDirectoryPath];
//    [cloneTask launch];
//    [cloneTask waitUntilExit];
//}
//
//
///// git rev-list HEAD --count
//NSUInteger commitsCount(NSString *workingDirectoryPath) {
//    NSTask *countTask = [NSTask new];
//    countTask.currentDirectoryPath = workingDirectoryPath;
//    countTask.launchPath = @"/usr/local/bin/git";
//    countTask.arguments = @[@"rev-list", @"HEAD", @"--count"];
//
//    NSPipe *countPipe = [NSPipe pipe];
//    [countTask setStandardOutput:countPipe];
//    [countTask launch];
//    [countTask waitUntilExit];
//
//    NSFileHandle *readCommitCount = [countPipe fileHandleForReading];
//    NSString *commitsCount = [[NSString alloc] initWithData:[readCommitCount readDataToEndOfFile] encoding:NSUTF8StringEncoding];
//
//    return commitsCount.integerValue;
//}
//
//
///// git reset --hard HEAD~1
//void goBack(NSString *workingDirectoryPath) {
//    NSTask *revertTask = [NSTask new];
//    [revertTask setStandardOutput:[NSPipe pipe]];
//    revertTask.currentDirectoryPath = workingDirectoryPath;
//    revertTask.launchPath = @"/usr/local/bin/git";
//    revertTask.arguments = @[@"reset", @"--hard", @"HEAD~1"];
//    [revertTask setTerminationHandler:^(NSTask *task){
//        if ([task terminationStatus] != EXIT_SUCCESS) {
//            NSLog(@"Revert failed...");
//        }
//    }];
//    [revertTask launch];
//    [revertTask waitUntilExit];
//}
//
//void writeStats(NSString *workingDirectoryPath) {
//    // Get current commit hash
//    // git rev-parse HEAD
//    NSTask *hashTask = [NSTask new];
//    hashTask.currentDirectoryPath = workingDirectoryPath;
//    hashTask.launchPath = @"/usr/local/bin/git";
//    hashTask.arguments = @[@"rev-parse", @"HEAD"];
//
//    NSPipe *hashPipe = [NSPipe pipe];
//    [hashTask setStandardOutput:hashPipe];
//    [hashTask launch];
//    [hashTask waitUntilExit];
//
//    NSFileHandle *readCommithash = [hashPipe fileHandleForReading];
//    NSString *currentHash = [[[NSString alloc] initWithData:[readCommithash readDataToEndOfFile] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//
//    // Count and write a file
//    // cloc ./ --json --out ./out.json
//    NSTask *clocTask = [NSTask new];
//    [clocTask setStandardOutput:[NSPipe pipe]];
//    clocTask.currentDirectoryPath = workingDirectoryPath;
//    clocTask.launchPath = @"/usr/local/bin/cloc";
//    NSString *statsFileName = [NSString stringWithFormat:@"./%@.json", currentHash];
//    clocTask.arguments = @[@"./", @"--json", @"--out", statsFileName];
//    [clocTask launch];
//    [clocTask waitUntilExit];
//}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //NSString *repoPath = @"git@github.com:techery/appspector-ios-sdk.git";
        NSURL *repoURL = [NSURL URLWithString:@"git@github.com:deszip/repo-stats.git"];
        NSURL *workingDirectoryURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/tmp/%@", repoURL.lastPathComponent]];
        
        STGitWalker *walker = [[STGitWalker alloc] initWithRepoURL:repoURL workingDirectory:workingDirectoryURL];
        BOOL envReady = [walker prepareEnv];
        
        if (!envReady) {
            return EXIT_FAILURE;
        }
        
        [walker startProcessing];
        
        // Check working directory
//        NSString *workingDirectoryPath = [NSString stringWithFormat:@"/tmp/%@", repoPath.lastPathComponent];
//        BOOL isDir;
//        if ([[NSFileManager defaultManager] fileExistsAtPath:workingDirectoryPath isDirectory:&isDir]) {
//            NSLog(@"Working directory exists at %@, cleaning...", workingDirectoryPath);
//            NSError *cleanError;
//            if (![[NSFileManager defaultManager] removeItemAtPath:workingDirectoryPath error:&cleanError]) {
//                NSLog(@"Failed to remove working directory at %@, %@", workingDirectoryPath, cleanError);
//                return EXIT_FAILURE;
//            }
//        }
        
//        // Get repo
//        cloneRepo(repoPath, workingDirectoryPath);
//
//        // Parameters
//        NSUInteger depth = commitsCount(workingDirectoryPath);
//        NSLog(@"Got %lu commits", (unsigned long)depth);
//
//        NSTimeInterval totalStepTime = 0;
//        NSTimeInterval averageStepTime = 0;
//
//        // Write stats
//        for (NSUInteger i = 0; i < depth; i++) {
//            NSLog(@"Getitng stats for commit %lu", depth - i);
//
//            NSDate *startDate = [NSDate date];
//
//            writeStats(workingDirectoryPath);
//            goBack(workingDirectoryPath);
//
//            NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:startDate];
//            totalStepTime += elapsed;
//            averageStepTime = totalStepTime / (i + 1);
//            NSLog(@"Finished step %lu in %f, average: %f, total: %f", (unsigned long)i, elapsed, averageStepTime, totalStepTime);
//        }
//
    }
    
    return EXIT_SUCCESS;
}
