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
    [revertTask launch];
    [revertTask waitUntilExit];
    
    return success;
}

- (STCommit *)getStats:(NSString *)commitHash {
    NSTask *task = [NSTask new];
    [task setStandardOutput:[NSPipe pipe]];
    task.currentDirectoryPath = self.workingDirectory.path;
    task.launchPath = @"/usr/bin/git";
    task.arguments = @[@"checkout", commitHash];
    [task launch];
    [task waitUntilExit];

    STCommit *commit = [STCommit new];
    commit.commitDate = [self commitDate:commitHash];
    commit.commitHash = commitHash;
    commit.totalLineCount = [self lineCount];

    return commit;
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

- (NSUInteger)lineCount {
    NSArray *prefetchedProperties = @[
        NSURLIsRegularFileKey,
        NSURLFileAllocatedSizeKey,
        NSURLTotalFileAllocatedSizeKey,
    ];

    __block BOOL errorDidOccur = NO;
    BOOL (^errorHandler)(NSURL *, NSError *) = ^(NSURL *url, NSError *localError) {
        if (localError != NULL) {
            NSLog(@"Enumerator failed:\n\tURL: %@\n\tError: %@", url, localError);
        }
        return NO;
    };

    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:self.workingDirectory
                                                             includingPropertiesForKeys:prefetchedProperties
                                                                                options:(NSDirectoryEnumerationOptions)0
                                                                           errorHandler:errorHandler];

    NSArray *supportedExtensions = @[@"m", @"h", @"swift", @"c", @"mm", @"hpp"];
    NSUInteger totalCount = 0;
    for (NSURL *itemURL in enumerator) {
        if ([supportedExtensions containsObject:itemURL.pathExtension]) {
            NSError *error;
            NSString *contents = [NSString stringWithContentsOfURL:itemURL encoding:NSUTF8StringEncoding error:&error];
            if (contents) {
                totalCount += [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].count;
            } else {
                NSLog(@"Failed to get file contentsat: %@, %@", itemURL, error);
            }
        }
    }

    return totalCount;
}

- (NSDate *)commitDate:(NSString *)commitHash {
    // git show -s --format=%ct
    NSTask *task = [NSTask new];
    task.currentDirectoryPath = self.workingDirectory.path;
    task.launchPath = @"/usr/bin/git";
    task.arguments = @[@"show", @"-s", @"--format=%ct", commitHash];

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task launch];
    [task waitUntilExit];

    NSFileHandle *readHandle = [pipe fileHandleForReading];
    NSString *output = [[[NSString alloc] initWithData:[readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    return [NSDate dateWithTimeIntervalSince1970:output.doubleValue];;
}

@end
