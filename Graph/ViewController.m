//
//  ViewController.m
//  Graph
//
//  Created by Inna Labuns'ka on 13.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import "ViewController.h"
#import "NodeView.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

static NSUInteger NodeSize = 30;
static NSUInteger const NodeDistance = 5;
static double const CircleDistance = 40.0;
static double const GenerationDistance = 100.0;

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) Graph *graph;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic) NSUInteger gestureCount;
@property (nonatomic) BOOL buildInProgress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gestureCount = 0;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.containerView.frame.size;
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchWithGestureRecognizer:)];
    [self.scrollView addGestureRecognizer:pinchGestureRecognizer];
    self.graph = [[Graph alloc] initGraphWithRootLink:@"http://www.raywenderlich.com"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateNodesView];
}

- (void)updateNodesView
{
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    Node *rootNode = self.graph.rootNode;
    NSUInteger currentGenerationLevel = 0;
    NSMutableSet *visitedNodes = [NSMutableSet set];
    NSMutableArray *currentGeneration = [NSMutableArray array];
    NSMutableSet *nextGeneration = [NSMutableSet set];
    NSMutableArray *Generations = [NSMutableArray array];
    [currentGeneration addObject:rootNode];
    double minRadius = 0;
    
    
    [Generations addObject:currentGeneration];

    for (NSMutableArray *generation in Generations) {
    
        [visitedNodes addObjectsFromArray:generation];
        NSUInteger nodesCount = generation.count;
        NSUInteger circles = [self circlesForNodesCount:nodesCount withMinRadius:minRadius];
        double dAlpha = 1.95 * M_PI / nodesCount;
        double alpha = 0;
        NSUInteger currentCircle = 0;
        for(Node *node in generation) {
            NodeView *nodeView = [self nodeViewForNode:node withGeneration:currentGenerationLevel];
            double radius = minRadius + currentCircle * CircleDistance;
            nodeView.center = CGPointMake(radius * cos(alpha), radius * sin(alpha));
            currentCircle = (currentCircle + 1) % circles;
            alpha += dAlpha;
            [self.containerView addSubview:nodeView];
             minRadius += circles * CircleDistance + GenerationDistance;
//            [Generations addObjectsFromArray:children];
        }
     
        
        for(Node*node in generation) {
        NSArray *children = [self.graph firstGenerationFromNode:node];
            [nextGeneration addObjectsFromArray:children];

        [nextGeneration minusSet:visitedNodes];
        [generation addObjectsFromArray:[nextGeneration allObjects]];
        [nextGeneration removeAllObjects];
        [Generations addObject:generation];
        currentGenerationLevel++;
        }
        NSUInteger width = MAX(2*minRadius, self.view.frame.size.width);
        NSUInteger height = MAX(2*minRadius, self.view.frame.size.height);
        [self.containerView setFrame:CGRectMake(0, 0, width, height)];
        [self.scrollView setContentSize:CGSizeMake(width, height)];
        CGAffineTransform move = CGAffineTransformMakeTranslation(width/2, height/2);
        for (NodeView *nodeView in self.containerView.subviews) {
            [nodeView setTransform:move];
        }

    }
    
    
    
    
//    do {
//        [visitedNodes addObjectsFromArray:currentGeneration];
//
//        NSUInteger nodesCount = currentGeneration.count;
//        NSUInteger circles = [self circlesForNodesCount:nodesCount withMinRadius:minRadius];
//        double dAlpha = 1.95 * M_PI / nodesCount;
//        double alpha = 0;
//        NSUInteger currentCircle = 0;
//        for (Node *node in currentGeneration) {
//            NodeView *nodeView = [self nodeViewForNode:node withGeneration:currentGenerationLevel];
//            double radius = minRadius + currentCircle*CircleDistance;
//            nodeView.center = CGPointMake(radius * cos(alpha), radius * sin(alpha));
//            currentCircle = (currentCircle + 1) % circles;
//            alpha += dAlpha;
//            [self.containerView addSubview:nodeView];
//        }
//        minRadius += circles * CircleDistance + GenerationDistance;
//        
//        while (currentGeneration.count) {
//            Node *node = currentGeneration.lastObject;
//            [currentGeneration removeObject:node];
//            NSArray *children = [self.graph firstGenerationFromNode:node];
//            [nextGeneration addObjectsFromArray:children];
//        }
//
//        [nextGeneration minusSet:visitedNodes];
//        [currentGeneration addObjectsFromArray:[nextGeneration allObjects]];
//        [nextGeneration removeAllObjects];
//        currentGenerationLevel++;
//    } while (currentGeneration.count);
//    
//    NSUInteger width = MAX(2*minRadius, self.view.frame.size.width);
//    NSUInteger height = MAX(2*minRadius, self.view.frame.size.height);
//    [self.containerView setFrame:CGRectMake(0, 0, width, height)];
//    [self.scrollView setContentSize:CGSizeMake(width, height)];
//    CGAffineTransform move = CGAffineTransformMakeTranslation(width/2, height/2);
//    for (NodeView *nodeView in self.containerView.subviews) {
//        [nodeView setTransform:move];
//    }
}

- (NodeView*)nodeViewForNode:(Node*)node withGeneration:(NSUInteger)generation
{
    NodeView *nodeView = [[NodeView alloc] initWithFrame:CGRectMake(0, 0, NodeSize, NodeSize)];
    nodeView.node = node;
    nodeView.layer.cornerRadius = NodeSize/2;
    nodeView.layer.masksToBounds = YES;
    nodeView.alpha = 1.0 / (generation + 1.0);
    //NodeSize = NodeSize/(generation + 1.0);
    return nodeView;
}

- (NSUInteger)circlesForNodesCount:(NSUInteger)nodesCount withMinRadius:(double)minRadius
{
    NSUInteger countForMinCircle = MAX(1, [self nodesCountForRadius:minRadius]);
    return ((nodesCount - 1) / countForMinCircle) + 1;
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Line tap was here: %@", recognizer.view);
}
- (void)handleSingleTapNodeView:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"Node tap happened: x = %@, y = %@", @(recognizer.view.center.x), @(recognizer.view.center.y));
}

- (float)circleRadiusForNodeCount:(NSUInteger)nodeCount
{
    return 0.5 * M_1_PI * nodeCount * (NodeSize + NodeDistance);
}

- (NSUInteger)nodesCountForRadius:(float)radius
{
    return 2 * M_PI * radius / (NodeSize + NodeDistance);
}

-(void)handlePinchWithGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
 
        switch (pinchGestureRecognizer.state) {
        case UIGestureRecognizerStateRecognized: {
            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>");
            self.gestureCount++;
            [self asyncBuildNextGeneration];
        } break;

        default: {
        } break;
    }
}

- (void)asyncBuildNextGeneration
{
    if (self.gestureCount > 0 && !self.buildInProgress) {
        self.buildInProgress = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.graph buildNextGeneration];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.gestureCount--;
                self.buildInProgress = NO;
                [self updateNodesView];
                [self asyncBuildNextGeneration];
            });
        });
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;//self.containerView;
}

@end
