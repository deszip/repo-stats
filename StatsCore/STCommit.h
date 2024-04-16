//
//  STCommit.h
//  StatsCore
//
//  Created by Deszip on 16.04.2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STCommit : NSObject

@property (copy, nonatomic) NSString *commitHash;
@property (strong, nonatomic) NSDate *commitDate;
@property (assign, nonatomic) NSUInteger totalLineCount;

@end

NS_ASSUME_NONNULL_END
