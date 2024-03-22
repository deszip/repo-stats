//
//  STRepoStorage.m
//  StatsCore
//
//  Created by Deszip on 22.03.2024.
//

#import "STRepoStorage.h"

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

}

- (void)removeRepo:(NSUUID *)repoID {
    
}


@end
