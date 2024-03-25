//
//  STRepoStorage.m
//  StatsCore
//
//  Created by Deszip on 22.03.2024.
//

#import "STRepoStorage.h"

#import "STRepo+CoreDataClass.h"

@interface STRepoStorage ()

@property(strong, nonatomic) NSManagedObjectContext *context;

@end

@implementation STRepoStorage

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        _context = context;
    }

    return self;
}

- (void)addRepo:(NSString *)name path:(NSString *)path {
    [self.context performBlock:^{
        STRepo *repo = [[STRepo alloc] initWithContext:self.context];
        repo.repoID = [NSUUID UUID];
        repo.name = name;
        repo.path = path;

        [self save];
    }];
}

- (void)removeRepo:(NSUUID *)repoID {
    [self.context performBlock:^{
        NSFetchRequest *reposRequest = [STRepo fetchRequest];
        reposRequest.predicate = [NSPredicate predicateWithFormat:@"repoID = %@", repoID];
        NSError *fetchError;
        NSArray <STRepo *> *repos = [self.context executeFetchRequest:reposRequest error:&fetchError];
        if (!repos) {
            NSLog(@"Failed to fetch repos: %@", fetchError);
            return;
        }

        if (repos.count > 0) {
            [self.context deleteObject:repos.firstObject];
            [self save];
        }
    }];
}

- (void)save {
    if ([self.context hasChanges]) {
        NSError *error;
        if (![self.context save:&error]) {
            NSLog(@"Failed to save context: %@", error);
        }
    }
}

@end
