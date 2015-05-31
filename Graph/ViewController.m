//
//  ViewController.m
//  Graph
//
//  Created by Inna Labuns'ka on 13.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import "ViewController.h"
#import "NodeView.h"

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) Graph *graph;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.containerView.frame = CGRectMake(0, 0, 400, 800);
    self.scrollView.contentSize = self.containerView.frame.size;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.containerView.frame.size;
    
    self.graph = [[Graph alloc] initGraphWithRootLink:@"http://www.raywenderlich.com"];
    [self.graph breadthFirstSearchFromNode:self.graph.rootNode handler:^(NodeForURL *node) {
        
        NodeView *nodeView = [[NodeView alloc] initViewForNode:node];
        nodeView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:1.0 animations:^{
            nodeView.transform = CGAffineTransformMakeScale(1, 1);
        }];
        nodeView.center = CGPointMake(arc4random()%400, arc4random()%800);
        [self.containerView addSubview:nodeView];
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;//self.containerView;
}

@end
