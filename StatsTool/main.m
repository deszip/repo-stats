//
//  main.m
//  StatsTool
//
//  Created by Deszip on 21.02.2021.
//

#import <Foundation/Foundation.h>


/// git clone --single-branch --branch [branch_name] [repo_url]
void cloneRepo(NSString *repoPath, NSString *workingDirectoryPath, NSString *branch) {
    NSTask *cloneTask = [NSTask new];
    cloneTask.launchPath = @"/usr/bin/git";
    cloneTask.arguments = @[@"clone", @"--single-branch", @"--branch", branch, repoPath, workingDirectoryPath];
    [cloneTask launch];
    [cloneTask waitUntilExit];
}


/// git rev-list HEAD --count
NSUInteger commitsCount(NSString *workingDirectoryPath) {
    NSTask *countTask = [NSTask new];
    countTask.currentDirectoryPath = workingDirectoryPath;
    countTask.launchPath = @"/usr/bin/git";
    countTask.arguments = @[@"rev-list", @"HEAD", @"--count"];
    
    NSPipe *countPipe = [NSPipe pipe];
    [countTask setStandardOutput:countPipe];
    [countTask launch];
    [countTask waitUntilExit];
    
    NSFileHandle *readCommitCount = [countPipe fileHandleForReading];
    NSString *commitsCount = [[NSString alloc] initWithData:[readCommitCount readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    
    return commitsCount.integerValue;
}


/// git reset --hard HEAD~1
void goBack(NSString *workingDirectoryPath) {
    NSTask *revertTask = [NSTask new];
    [revertTask setStandardOutput:[NSPipe pipe]];
    revertTask.currentDirectoryPath = workingDirectoryPath;
    revertTask.launchPath = @"/usr/bin/git";
    revertTask.arguments = @[@"reset", @"--hard", @"HEAD~1"];
    [revertTask setTerminationHandler:^(NSTask *task){
        if ([task terminationStatus] != EXIT_SUCCESS) {
            NSLog(@"Revert failed...");
        }
    }];
    [revertTask launch];
    [revertTask waitUntilExit];
}

void writeStats(NSString *workingDirectoryPath) {
    // Get current commit hash
    // git rev-parse HEAD
    NSTask *hashTask = [NSTask new];
    hashTask.currentDirectoryPath = workingDirectoryPath;
    hashTask.launchPath = @"/usr/bin/git";
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
    
    
    /// @param repo ssh path to the repo
    /// @param branch repo branch to work with
    /// @param depth number of commits to go back, optional, default is all commits
    /// @param step number of commits for iteration, default is 1
    /// @param output_path path to store stats files
    
    
    @autoreleasepool {
        //NSString *repoPath = @"git@github.com:techery/appspector-ios-sdk.git";
        NSString *repoPath = @"git@github.com:deszip/repo-stats.git";
    
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
        cloneRepo(repoPath, workingDirectoryPath, @"develop");
                
        // Parameters
        NSUInteger depth = commitsCount(workingDirectoryPath);
        NSLog(@"Got %lu commits", (unsigned long)depth);
        
        NSTimeInterval totalStepTime = 0;
        NSTimeInterval averageStepTime = 0;
        
        // Write stats
        for (NSUInteger i = 0; i < depth; i++) {
            NSLog(@"Getitng stats for commit %lu", depth - i);
            NSDate *startDate = [NSDate date];

            // Write stats for current revision
            writeStats(workingDirectoryPath);
            
            // If it's not the last commit, go one commit back
            if (i < depth - 1) {
                goBack(workingDirectoryPath);
            }
            
            // Calculate stats
            NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:startDate];
            totalStepTime += elapsed;
            averageStepTime = totalStepTime / (i + 1);
            NSLog(@"Finished step %lu in %f, average: %f, total: %f", (unsigned long)i, elapsed, averageStepTime, totalStepTime);
        }
        
        
    }
    
    return EXIT_SUCCESS;
}
