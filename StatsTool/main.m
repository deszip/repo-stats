//
//  main.m
//  StatsTool
//
//  Created by Deszip on 21.02.2021.
//

#import <Foundation/Foundation.h>

#import "STGitWalker.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //NSString *repoPath = @"git@github.com:techery/appspector-ios-sdk.git";
        NSURL *repoURL = [NSURL URLWithString:@"git@github.com:deszip/repo-stats.git"];
        NSURL *workingDirectoryURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/tmp/%@", repoURL.lastPathComponent]];
        NSURL *clocOutputURL = [NSURL fileURLWithPath:@"/tmp/cloc_out"];
        
        STClocMetric *clocMetric = [[STClocMetric alloc] initWithOutputDirectory:clocOutputURL supportContinuation:YES];
        STGitWalker *walker = [[STGitWalker alloc] initWithRepoURL:repoURL workingDirectory:workingDirectoryURL clocMetric:clocMetric];
        BOOL envReady = [walker prepareEnv];
        
        if (!envReady) {
            return EXIT_FAILURE;
        }
        
        [walker startProcessing];
    }
    
    return EXIT_SUCCESS;
}
