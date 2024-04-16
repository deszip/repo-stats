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

- (instancetype)initWithWorkingDIrectory:(NSURL *)workingDirectory {
    if (self = [super init]) {
        _workingDirectory = workingDirectory;
    }
    
    return self;
}

/// git clone --single-branch --branch [branch_name] [repo_url]
- (void)cloneRepo:(NSString *)repoPath branch:(NSString *)branch {
    NSTask *cloneTask = [NSTask new];

    NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];
    // Environment variables needed for password based authentication
    NSString *askPassPath = [NSBundle pathForResource:@"Stats"
                  ofType:@""
                  inDirectory:[[NSBundle mainBundle] bundlePath]];
    NSMutableDictionary *env = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                             @"NONE", @"DISPLAY",                           askPassPath, @"SSH_ASKPASS",
                             @"deszip",@"AUTH_USERNAME",
                             @"github.com",@"AUTH_HOSTNAME",
                             nil];
     
    // Environment variable needed for key based authentication
//    [env setObject:[environmentDict objectForKey:@"SSH_AUTH_SOCK"] forKey:@"SSH_AUTH_SOCK"];
     
    // Setting the task's environment
//    [cloneTask setEnvironment:env];
//    [cloneTask setEnvironment:environmentDict];
    
    cloneTask.launchPath = @"/usr/bin/git";
    cloneTask.arguments = @[@"clone", @"--single-branch", @"--branch", branch, repoPath, self.workingDirectory.path];
    [cloneTask launch];
    [cloneTask waitUntilExit];
}

/// git rev-list HEAD --count
- (NSUInteger)commitsCount {
    NSTask *countTask = [NSTask new];
    countTask.currentDirectoryPath = self.workingDirectory.path;
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
- (BOOL)goBack {
    __block BOOL success = YES;
    
    NSTask *revertTask = [NSTask new];
    [revertTask setStandardOutput:[NSPipe pipe]];
    revertTask.currentDirectoryPath = self.workingDirectory.path;
    revertTask.launchPath = @"/usr/bin/git";
    revertTask.arguments = @[@"reset", @"--hard", @"HEAD~1"];
    [revertTask setTerminationHandler:^(NSTask *task){
        if ([task terminationStatus] != EXIT_SUCCESS) {
            NSLog(@"Revert failed...");
            success = NO;
        }
    }];
    [revertTask launch];
    [revertTask waitUntilExit];
    
    return success;
}

- (NSString *)getStats {
    // Get current commit hash
    // git rev-parse HEAD
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
}

@end
