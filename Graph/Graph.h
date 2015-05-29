//
//  Graph.h
//  Graph
//
//  Created by Inna Labuns'ka on 13.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NodeForURL.h"

@interface Graph : NSObject

@property (nonatomic, strong, readonly) NSString *rootUrl;
@property (nonatomic, strong, readonly) NSMutableDictionary *nodes;
@property (nonatomic, strong, readonly) NodeForURL *rootNode;

- (instancetype)initGraphWithRootLink:(NSString*)rootUrl;
- (void)addNode:(NodeForURL *)node;
- (NodeForURL*)nodeForUrl:(NSString*)url;
- (void)buildSiteMap;
- (void)buildSiteMapWithMaxIterations:(NSUInteger)maxIter;
- (void)parseNode:(NodeForURL *)node;
- (void)breadthFirstSearchFromNode:(NodeForURL*)node handler:(void(^)(NodeForURL* node))handler;

- (void)buildNextGeneration;
- (NSArray*)firstGenerationFromNode:(NodeForURL*)node;

@end
