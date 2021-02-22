//
//  main.m
//  StatsTool
//
//  Created by Deszip on 21.02.2021.
//

#import <Foundation/Foundation.h>

void goBack(NSString *workingDirectoryPath) {
    // Revert one commit
    // git reset --hard HEAD~1
    NSTask *revertTask = [NSTask new];
    [revertTask setStandardOutput:[NSPipe pipe]];
    revertTask.currentDirectoryPath = workingDirectoryPath;
    revertTask.launchPath = @"/usr/local/bin/git";
    revertTask.arguments = @[@"reset", @"--hard", @"HEAD~1"];
    [revertTask launch];
    [revertTask waitUntilExit];
}

void writeStats(NSString *workingDirectoryPath) {
    // Get current commit hash
    // git rev-parse HEAD
    NSTask *hashTask = [NSTask new];
    hashTask.currentDirectoryPath = workingDirectoryPath;
    hashTask.launchPath = @"/usr/local/bin/git";
    hashTask.arguments = @[@"rev-parse", @"HEAD"];
    
    NSPipe *hashPipe = [NSPipe pipe];
    [hashTask setStandardOutput:hashPipe];
    [hashTask launch];
    [hashTask waitUntilExit];
    
    NSFileHandle *readCommithash = [hashPipe fileHandleForReading];
    NSString *currentHash = [[[NSString alloc] initWithData:[readCommithash readDataToEndOfFile] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Count and write a file
    // cloc ./ --json --out ./out.json
    NSTask *clocTask = [NSTask new];
    [clocTask setStandardOutput:[NSPipe pipe]];
    clocTask.currentDirectoryPath = workingDirectoryPath;
    clocTask.launchPath = @"/usr/local/bin/cloc";
    NSString *statsFileName = [NSString stringWithFormat:@"./%@.json", currentHash];
    clocTask.arguments = @[@"./", @"--json", @"--out", statsFileName];
    [clocTask launch];
    [clocTask waitUntilExit];
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /**
         - git clone ...
         - git rev-list --count <revision> - count
         
         - git rev-parse HEAD - current hash
         - git reset --hard HEAD~1 - one back
         
         */
        
        NSString *repoPath = @"git@github.com:techery/appspector-ios-sdk.git";
        
        // Check working directory
        NSString *workingDirectoryPath = [NSString stringWithFormat:@"/tmp/%@", repoPath.lastPathComponent];
        BOOL isDir;
        if ([[NSFileManager defaultManager] fileExistsAtPath:workingDirectoryPath isDirectory:&isDir]) {
            NSLog(@"Working directory exists at %@, cleaning...", workingDirectoryPath);
            NSError *cleanError;
            if (![[NSFileManager defaultManager] removeItemAtPath:workingDirectoryPath error:&cleanError]) {
                NSLog(@"Failed to remove working directory at %@, %@", workingDirectoryPath, cleanError);
                return EXIT_FAILURE;
            }
        }
        
        // Get repo
        // git clone
        NSTask *cloneTask = [NSTask new];
        cloneTask.launchPath = @"/usr/local/bin/git";
        cloneTask.arguments = @[@"clone", repoPath, workingDirectoryPath];
        [cloneTask launch];
        [cloneTask waitUntilExit];
        
        // Count commits
        // git rev-list HEAD --count
        NSTask *countTask = [NSTask new];
        countTask.currentDirectoryPath = workingDirectoryPath;
        countTask.launchPath = @"/usr/local/bin/git";
        countTask.arguments = @[@"rev-list", @"HEAD", @"--count"];
        
        NSPipe *countPipe = [NSPipe pipe];
        [countTask setStandardOutput:countPipe];
        [countTask launch];
        [countTask waitUntilExit];
        
        NSFileHandle *readCommitCount = [countPipe fileHandleForReading];
        NSString *commitsCount = [[NSString alloc] initWithData:[readCommitCount readDataToEndOfFile] encoding:NSUTF8StringEncoding];
                
        NSUInteger depth = commitsCount.integerValue;
        //NSUInteger depth = 3;
        NSTimeInterval totalStepTime = 0;
        NSTimeInterval averageStepTime = 0;
        
        for (NSUInteger i = 0; i < depth; i++) {
            NSDate *startDate = [NSDate date];

            writeStats(workingDirectoryPath);
            goBack(workingDirectoryPath);
            
            NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:startDate];
            totalStepTime += elapsed;
            averageStepTime = totalStepTime / (i + 1);
            NSLog(@"Finished step %lu in %f, average: %f, total: %f", (unsigned long)i, elapsed, averageStepTime, totalStepTime);
        }
        
    }
    
    return EXIT_SUCCESS;
}
