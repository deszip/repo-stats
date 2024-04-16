//
//  STGitToolkit.m
//  StatsCore
//
//  Created by Deszip on 03.04.2024.
//

#import "STGitToolkit.h"

@interface STGitToolkit ()

@property (strong, nonatomic) NSURL *workingDirectory;

@end

@implementation STGitToolkit

- (instancetype)initWithWorkingDirectory:(NSURL *)workingDirectory {
    if (self = [super init]) {
        _workingDirectory = workingDirectory;
    }
    
    return self;
}

/// git clone --single-branch --branch [branch_name] [repo_url]
- (void)cloneRepo:(NSString *)repoPath branch:(NSString *)branch {
    NSTask *cloneTask = [NSTask new];
    cloneTask.launchPath = @"/usr/bin/git";
//    NSString *pathWithCreds = [NSString stringWithFormat:@"https://%@:%@@%@", @"deszip", @"mg9i5#ew", [repoPath substringFromIndex:8]];
    NSString *pathWithCreds = repoPath;
    cloneTask.arguments = @[@"clone", @"--single-branch", @"--branch", branch, pathWithCreds, self.workingDirectory.path];
    [cloneTask launch];
    [cloneTask waitUntilExit];
}

/// git rev-list HEAD --count
- (NSUInteger)commitsCount {
    NSTask *countTask = [NSTask new];
    countTask.currentDirectoryPath = self.workingDirectory.path;
    countTask.launchPath = @"/usr/bin/git";
    countTask.arguments = @[@"rev-list", @"--count", [self currentBranch]];

    NSPipe *countPipe = [NSPipe pipe];
    [countTask setStandardOutput:countPipe];
    [countTask launch];
    [countTask waitUntilExit];
    
    NSFileHandle *readCommitCount = [countPipe fileHandleForReading];
    NSString *commitsCount = [[NSString alloc] initWithData:[readCommitCount readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    
    return commitsCount.integerValue;
}


/// git reset --hard HEAD~1
- (BOOL)goBack {
    __block BOOL success = YES;
    
    NSTask *revertTask = [NSTask new];
    [revertTask setStandardOutput:[NSPipe pipe]];
    revertTask.currentDirectoryPath = self.workingDirectory.path;
    revertTask.launchPath = @"/usr/bin/git";
    revertTask.arguments = @[@"reset", @"--hard", @"HEAD~1"];
//    [revertTask setTerminationHandler:^(NSTask *task){
//        if ([task terminationStatus] != EXIT_SUCCESS) {
//            NSLog(@"Revert failed...");
//            success = NO;
//        }
//    }];
    [revertTask launch];
    [revertTask waitUntilExit];
    
    return success;
}

- (NSString *)getStats:(NSString *)commit {
//    return [self currentCommitHash];

    // Count and write a file
    // cloc ./ --json --out ./out.json
    //    NSTask *clocTask = [NSTask new];
    //    [clocTask setStandardOutput:[NSPipe pipe]];
    //    clocTask.currentDirectoryPath = workingDirectoryPath;
    //    clocTask.launchPath = @"/usr/local/bin/cloc";
    //    NSString *statsFileName = [NSString stringWithFormat:@"./%@.json", currentHash];
    //    clocTask.arguments = @[@"./", @"--json", @"--out", statsFileName];
    //    [clocTask launch];
    //    [clocTask waitUntilExit];

    NSTask *task = [NSTask new];
    [task setStandardOutput:[NSPipe pipe]];
    task.currentDirectoryPath = self.workingDirectory.path;
    task.launchPath = @"/usr/bin/git";
    task.arguments = @[@"checkout", commit];
    [task launch];
    [task waitUntilExit];

    return [self currentCommitHash];
}

// Get current commit hash
// git rev-parse HEAD
- (NSString *)currentCommitHash {
    NSTask *hashTask = [NSTask new];
    hashTask.currentDirectoryPath = self.workingDirectory.path;
    hashTask.launchPath = @"/usr/bin/git";
    hashTask.arguments = @[@"rev-parse", @"HEAD"];

    NSPipe *hashPipe = [NSPipe pipe];
    [hashTask setStandardOutput:hashPipe];
    [hashTask launch];
    [hashTask waitUntilExit];

    NSFileHandle *readCommithash = [hashPipe fileHandleForReading];
    NSString *currentHash = [[[NSString alloc] initWithData:[readCommithash readDataToEndOfFile] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return currentHash;
}

// git rev-list --max-parents=1 [branch]
- (NSArray <NSString *> *)listCommits {
    NSTask *task = [NSTask new];
    task.currentDirectoryPath = self.workingDirectory.path;
    task.launchPath = @"/usr/bin/git";
    task.arguments = @[@"rev-list", @"--max-parents=1", [self currentBranch]];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];
    [task waitUntilExit];

    NSFileHandle *readHandle = [pipe fileHandleForReading];
    NSString *output = [[[NSString alloc] initWithData:[readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return [output componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

// git rev-parse --abbrev-ref HEAD
- (NSString *)currentBranch {
    NSTask *task = [NSTask new];
    task.currentDirectoryPath = self.workingDirectory.path;
    task.launchPath = @"/usr/bin/git";
    task.arguments = @[@"rev-parse", @"--abbrev-ref", @"HEAD"];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];
    [task waitUntilExit];

    NSFileHandle *readBranchName = [pipe fileHandleForReading];
    NSString *branchName = [[[NSString alloc] initWithData:[readBranchName readDataToEndOfFile] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return branchName;
}

//- (NSArray <>)

@end
