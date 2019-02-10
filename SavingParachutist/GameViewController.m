//
//  GameViewController.m
//  SavingParachutist
//
//  Created by Sebastian Natalevich on 1/7/17.
//  Copyright © 2017 Sebastian Natalevich. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Pause the view (and thus the game) when the app is interrupted or backgrounded
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActive:)  name:UIApplicationDidBecomeActiveNotification object:nil];
    
    SKView * skView = (SKView *)self.view;
    SKScene * scene = [GameScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.size = skView.bounds.size;
    
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)handleApplicationWillResignActive:(NSNotification*)note
{
    ((SKView*)self.view).paused = YES;
}

- (void)handleApplicationDidBecomeActive:(NSNotification*)note
{
    ((SKView*)self.view).paused = NO;
}

@end
