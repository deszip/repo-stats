//
//  STClocMetric.m
//  StatsTool
//
//  Created by Deszip on 06.02.2022.
//

#import "STClocMetric.h"

@interface STClocMetric()

@property (strong, nonatomic) NSURL *clocBinaryURL;

@end

@implementation STClocMetric

- (instancetype)initWithOutputDirectory:(NSURL *)outputDirectory supportContinuation:(BOOL)continuationEnabled {
    if (self = [super init]) {
        _outputDirectoryURL = outputDirectory;
        _continuationEnabled = continuationEnabled;
    }
    
    return self;
}

- (BOOL)prepareEnv {
    BOOL clocFound = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/opt/homebrew/bin/cloc"]) {
        self.clocBinaryURL = [NSURL fileURLWithPath:@"/opt/homebrew/bin/cloc"];
        clocFound = YES;
    }
    
    BOOL outputCreated = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.outputDirectoryURL.path]) {
        NSError *createError = nil;
        BOOL outputCreated = [[NSFileManager defaultManager] createDirectoryAtURL:self.outputDirectoryURL withIntermediateDirectories:YES attributes:nil error:&createError];

        NSLog(@"Creating output directory............[%@]", outputCreated ? @"OK" : @"FAIL");
    }
    
    BOOL outputWriteable = NO;
    if ([[NSFileManager defaultManager] isWritableFileAtPath:self.outputDirectoryURL.path]) {
        outputWriteable = YES;
    }
    
    NSLog(@"Checking cloc binary............[%@]", clocFound ? @"OK" : @"FAIL");
    NSLog(@"Checking output path............[%@]", outputWriteable ? @"OK" : @"FAIL");
    
    return clocFound && outputCreated && outputWriteable;
}

- (NSURL *)apply:(NSString *)commitHash {
    // Check if output file exists
    NSString *statsFileName = [NSString stringWithFormat:@"%@.json", commitHash];
    NSURL *outputFileURL = [NSURL fileURLWithPath:[self.outputDirectoryURL URLByAppendingPathComponent:statsFileName].path];

    // Drop if exists
    BOOL outputFound = [[NSFileManager defaultManager] fileExistsAtPath:outputFileURL.path];
    if (outputFound) {
        if (self.continuationEnabled) {
            return outputFileURL;
        }
        
        NSError *cleanError;
        if (![[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:&cleanError]) {
            NSLog(@"Failed to remove output file at %@, %@", outputFileURL.path, cleanError);
            return nil;
        }
    }
    
    // Count and write a file
    // cloc ./ --json --out ./out.json
    NSTask *clocTask = [NSTask new];
    [clocTask setStandardOutput:[NSPipe pipe]];
    clocTask.currentDirectoryPath = self.outputDirectoryURL.path;
    clocTask.executableURL = self.clocBinaryURL;
    clocTask.arguments = @[@"./", @"--json", @"--out", statsFileName];
    [clocTask launch];
    [clocTask waitUntilExit];
    
    return [NSURL fileURLWithPath:[self.outputDirectoryURL URLByAppendingPathComponent:statsFileName].path];
}

@end
