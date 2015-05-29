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
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic) NSUInteger gestureCount;
@property (nonatomic) BOOL buildInProgress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gestureCount = 0;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1500, 1500)];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1500, 1500)];
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.containerView.frame.size;
    
    self.graph = [[Graph alloc] initGraphWithRootLink:@"http://www.raywenderlich.com"];
    [self.graph breadthFirstSearchFromNode:self.graph.rootNode handler:^(NodeForURL *node) {
        NodeView *nodeView = [self nodeViewForNode:node];
        [self.scrollView addSubview:nodeView];
    }];
    
}
- (void)updateNodesView
{
    NSArray *generations = [self arrayWithGenerations];
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    double minRadius = 0;
    for (NSUInteger level = 0; level < generations.count; ++level) {
        NSArray *generation = generations[level];
        
        NSUInteger nodesCount = generation.count;
        NSUInteger circles = [self circlesForNodesCount:nodesCount withMinRadius:minRadius];
        double dAlpha = 1.95 * M_PI / nodesCount;
        double alpha = 0;
        NSUInteger currentCircle = 0;
        for(NodeForURL *node in generation) {
            NodeView *nodeView = [self nodeViewForNode:node];
            double radius = minRadius + currentCircle * CircleDistance;
            nodeView.center = CGPointMake(radius * cos(alpha), radius * sin(alpha));
            currentCircle = (currentCircle + 1) % circles;
            alpha += dAlpha;
            [self.containerView addSubview:nodeView];
        }
        minRadius += circles * CircleDistance + GenerationDistance;
    }
    
//    NSUInteger width = MAX(2*minRadius, self.view.frame.size.width);
//    NSUInteger height = MAX(2*minRadius, self.view.frame.size.height);
//    [self.containerView setFrame:CGRectMake(0, 0, width, height)];
//    [self.scrollView setContentSize:CGSizeMake(width, height)];
//    CGAffineTransform move = CGAffineTransformMakeTranslation(width/2, height/2);
//    for (NodeView *nodeView in self.containerView.subviews) {
//        [nodeView setTransform:move];
//    }
}

- (NSArray*)arrayWithGenerations
{
    NodeForURL *rootNode = self.graph.rootNode;
    NSMutableSet *visitedNodes = [NSMutableSet set];
    NSMutableArray *currentGeneration = [NSMutableArray array];
    NSMutableSet *nextGeneration = [NSMutableSet set];
    NSMutableArray *Generations = [NSMutableArray array];
    [currentGeneration addObject:rootNode];
    [Generations addObject:currentGeneration];
    
    for (NSUInteger i = 0; i < Generations.count; ++i) {
        NSArray *generation = Generations[i];
        [visitedNodes addObjectsFromArray:generation];
        for (NodeForURL *node in generation) {
            NSArray *children = [self.graph firstGenerationFromNode:node];
            [nextGeneration addObjectsFromArray:children];
        }
        [nextGeneration minusSet:visitedNodes];
        if (nextGeneration.count) {
            [Generations addObject:[nextGeneration allObjects]];
            [nextGeneration removeAllObjects];
        }
    }
    return Generations;
}

- (NodeView*)nodeViewForNode:(NodeForURL*)node
{
   // NSUInteger nodeSize = NodeSize - MIN(25, 5*generation);
    NodeView *nodeView = [[NodeView alloc] initWithFrame:CGRectMake(10, 10, NodeSize, NodeSize)];
    //NodeView *nodeView = [[[NSBundle mainBundle] loadNibNamed:@"CircleNodeView" owner:self options:nil]objectAtIndex:0];
    nodeView.node = node;
    //nodeView.layer.cornerRadius = NodeSize/2;
    CAShapeLayer *circle = [CAShapeLayer layer];
    
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(10, 10, NodeSize, NodeSize)cornerRadius:NodeSize].CGPath;
    circle.masksToBounds = NO;
    circle.shadowOffset = CGSizeMake(-5, 10);
    circle.shadowRadius = 5;
    circle.shadowOpacity = 0.5;
    circle.position = CGPointMake(CGRectGetMidX(nodeView.frame)-NodeSize/2,
                                  CGRectGetMidY(nodeView.frame)-NodeSize/2);
        if (node.countURLs > 0 && node.countURLs < 5) {
            circle.fillColor = [[UIColor redColor] CGColor];
        } else if (node.countURLs >= 5 && node.countURLs < 10) {
            circle.fillColor = [[UIColor yellowColor] CGColor];
        } else if (node.countURLs >=10 && node.countURLs < 20) {
            circle.fillColor = [[UIColor orangeColor] CGColor];
        } else if (node.countURLs >=20 && node.countURLs < 30) {
            circle.fillColor = [[UIColor purpleColor] CGColor];
        } else if (node.countURLs >=30 && node.countURLs < 50) {
            circle.fillColor = [[UIColor greenColor] CGColor];
        } else if (node.countURLs >=50 && node.countURLs <100) {
            circle.fillColor = [[UIColor blueColor] CGColor];
        } else if (node.countURLs >= 100 && node.countURLs <200) {
            circle.fillColor = [[UIColor magentaColor] CGColor];
        } else {
            circle.fillColor = [[UIColor cyanColor] CGColor];
        }

    [nodeView.layer addSublayer:circle];
   // nodeView.alpha = 1.0 / (generation + 1.0);

//    nodeView.layer.masksToBounds = YES;
//    nodeView.alpha = 1.0 / (generation + 1.0);
//    if (node.countURLs > 0 && node.countURLs < 5) {
//        nodeView.layer.backgroundColor = [[UIColor redColor] CGColor];
//    } else if (node.countURLs >= 5 && node.countURLs < 10) {
//        nodeView.layer.backgroundColor = [[UIColor yellowColor] CGColor];
//    } else if (node.countURLs >=10 && node.countURLs < 20) {
//        nodeView.layer.backgroundColor = [[UIColor orangeColor] CGColor];
//    } else if (node.countURLs >=20 && node.countURLs < 30) {
//        nodeView.layer.backgroundColor = [[UIColor purpleColor] CGColor];
//    } else if (node.countURLs >=30 && node.countURLs < 50) {
//        nodeView.layer.backgroundColor = [[UIColor greenColor] CGColor];
//    } else if (node.countURLs >=50 && node.countURLs <100) {
//        nodeView.layer.backgroundColor = [[UIColor blueColor] CGColor];
//    } else if (node.countURLs >= 100 && node.countURLs <200) {
//        nodeView.layer.backgroundColor = [[UIColor magentaColor] CGColor];
//    } else {
//        nodeView.layer.backgroundColor = [[UIColor cyanColor] CGColor];
//    }
    
    //NodeSize = NodeSize/(generation + 1.0);
    return nodeView;
}

- (NSUInteger)circlesForNodesCount:(NSUInteger)nodesCount withMinRadius:(double)minRadius
{
    NSUInteger countForMinCircle = MAX(1, [self nodesCountForRadius:minRadius]);
    return ((nodesCount - 1) / countForMinCircle) + 1;
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
