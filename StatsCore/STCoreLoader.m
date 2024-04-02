//
//  STCoreLoader.m
//  StatsCore
//
//  Created by Deszip on 22.03.2024.
//

#import "STCoreLoaderPrivate.h"
#import "STRepoStoragePrivate.h"

static NSString * const kSTGroupID = @"group.com.stats";

@interface STCoreLoader ()

@property (strong, nonatomic) NSPersistentContainer *container;
@property (strong, nonatomic) STRepoStorage *repoStorage;

@end

@implementation STCoreLoader

+ (instancetype)defaultLoader {
    static STCoreLoader *defaultLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultLoader = [STCoreLoader new];
    });

    return defaultLoader;
}

- (instancetype)init {
    if (self = [super init]) {
        //...
    }

    return self;
}

+ (void)loadCore {
    [[STCoreLoader defaultLoader] load];
}

- (void)load {
    self.container = [self buildContainerOfType:NSSQLiteStoreType atURL:[self storeURL]];
    NSLog(@"Loaded container: %@", self.container);

    self.repoStorage = [[STRepoStorage alloc] initWithContext:[self.container newBackgroundContext]];
    NSLog(@"Loaded storage: %@", self.repoStorage);
}

+ (STRepoStorage *)repoStorage {
    return [[STCoreLoader defaultLoader] repoStorage];
}

#pragma mark - Private

- (NSPersistentContainer *)buildContainerOfType:(NSString *)type atURL:(NSURL *)storeURL {
    NSPersistentStoreDescription *storeDescription = [NSPersistentStoreDescription new];
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"StatsStore"];
    storeDescription.URL = storeURL;
    storeDescription.type = type;
    storeDescription.shouldInferMappingModelAutomatically = YES;
    storeDescription.shouldMigrateStoreAutomatically = YES;
    container.persistentStoreDescriptions = @[storeDescription];
    [container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
        if (!storeDescription) {
            NSLog(@"Failed to load store: %@", error);
        }
    }];

    NSLog(@"Built store at: %@", storeURL);

    return container;
}

- (NSURL *)storeURL {
    NSURL *groupContainerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kSTGroupID];
    BOOL isDir = NO;
    BOOL containerExists = [[NSFileManager defaultManager] fileExistsAtPath:groupContainerURL.path isDirectory:&isDir];

    if (isDir && containerExists) {
        return [groupContainerURL URLByAppendingPathComponent:@"statsstore.sqlite"];
    }

    return nil;
}

@end
