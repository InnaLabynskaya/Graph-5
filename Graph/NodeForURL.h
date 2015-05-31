//
//  Node.h
//  Graph
//
//  Created by Inna Labuns'ka on 13.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface NodeForURL : NSObject <Node>

@property (strong, nonatomic, readonly) NSString *url;
@property (strong, nonatomic, readonly) NSMutableSet *edges;
@property (nonatomic, readonly) NSUInteger level;
@property (nonatomic) BOOL wasParsed;
@property (nonatomic) NSUInteger countURLs;

- (instancetype)initWithUrl:(NSString*)url andLevel:(NSUInteger)level;

- (void)addEdgeToNode:(NodeForURL *)node;
- (void)removeEdgeToNode:(NodeForURL *)node;
- (void)removeAllEdges;

@end
