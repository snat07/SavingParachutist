//
//  GameScene.m
//  SavingParachutist
//
//  Created by Sebastian Natalevich on 1/7/17.
//  Copyright © 2017 Sebastian Natalevich. All rights reserved.
//

#import "GameScene.h"
#import <CoreMotion/CoreMotion.h>
#import "GameOverScene.h"

// Collision Constants
static const u_int32_t kParachutistCategory = 0x1 << 0;
static const u_int32_t kBoatCategory        = 0x1 << 1;
static const u_int32_t kSceneEdgeCategory   = 0x1 << 2;

// Duration Fall down Level
static const int kMinDurationLevel1 = 4;
static const int kMaxDurationLevel1 = 5;
static const int kMinDurationLevel2 = 2;
static const int kMaxDurationLevel2 = 4;
static const int kMinDurationLevel3 = 2;
static const int kMaxDurationLevel3 = 3;
static const int kMinDurationLevel4 = 1;
static const int kMaxDurationLevel4 = 2;

// Score points Level
static const int kScoreLevel2 = 80;
static const int kScoreLevel3 = 200;
static const int kScoreLevel4 = 300;

// Nodes names
static NSString *const kBackrougnd  = @"background";
static NSString *const kSea         = @"sea";
static NSString *const kBoat        = @"boat";
static NSString *const kPlane       = @"plane";
static NSString *const kParachutist = @"parachutist";
static NSString *const kHeart       = @"heart";

static NSString *const kFont        = @"Futura-Bold";
static NSString *const kHighScore   = @"HighScore";


@interface GameScene ()

@property (nonatomic) SKSpriteNode *plane;
@property (nonatomic) SKSpriteNode *boat;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int score;
@property (nonatomic) int lives;
@property (nonatomic) SKLabelNode *scoreLabelNode;
@property (nonatomic) SKLabelNode *livesLabelNode;

@end

@implementation GameScene

#pragma mark - Scene Setup and Content Creation

- (void)didMoveToView:(SKView *)view {
    
    self.physicsWorld.contactDelegate = self;
    [self createContent];
}

- (void)createContent {
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = kSceneEdgeCategory;
    
    [self setupBackground];
    [self setupBoat];
    [self setupPlane];
    [self setupHud];
}

- (void)setupHud {
    self.score = 0;
    self.scoreLabelNode = [SKLabelNode labelNodeWithFontNamed:kFont];
    self.scoreLabelNode.fontSize  = 13;
    self.scoreLabelNode.position = CGPointMake(self.size.width - 50, self.size.height - 30);
    self.scoreLabelNode.fontColor = [UIColor blackColor];
    self.scoreLabelNode.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"score", nil), self.score];
    [self addChild:self.scoreLabelNode];
    
    self.lives = 3;
    SKSpriteNode *heart = [SKSpriteNode spriteNodeWithImageNamed:kHeart];
    heart.position = CGPointMake(self.scoreLabelNode.position.x - 60, self.size.height - 25);;
    self.livesLabelNode = [SKLabelNode labelNodeWithFontNamed:kFont];
    self.livesLabelNode.fontSize = 13;
    self.livesLabelNode.fontColor = [UIColor whiteColor];
    self.livesLabelNode.position = CGPointMake(0, -4);
    self.livesLabelNode.text = [NSString stringWithFormat:@"%d", self.lives];
    [self addChild:heart];
    [heart addChild:self.livesLabelNode];
}

- (void)setupBackground {
    SKSpriteNode* background = [SKSpriteNode spriteNodeWithImageNamed:kBackrougnd];
    background.position = CGPointMake(self.size.width/2,self.size.height/2);
    [self addChild:background];
    
    SKSpriteNode* sea = [SKSpriteNode spriteNodeWithImageNamed:kSea];
    sea.position = CGPointMake(self.size.width/2,-20);
    [self addChild:sea];
}

- (void)setupBoat {
    self.boat = [SKSpriteNode spriteNodeWithImageNamed:kBoat];
    
    self.boat.xScale = 0.4;
    self.boat.yScale = 0.4;
    self.boat.position = CGPointMake(self.size.width/2, 100);
    self.boat.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.boat.size.width/2, self.boat.frame.size.height/2)];
    self.boat.physicsBody.dynamic = YES;
    self.boat.physicsBody.affectedByGravity = NO;
    self.boat.physicsBody.mass = 0.02;
    self.boat.physicsBody.categoryBitMask = kBoatCategory;
    self.boat.physicsBody.contactTestBitMask = 0x0;
    self.boat.physicsBody.collisionBitMask = kSceneEdgeCategory;
    [self addChild:self.boat];

}

- (void)setupPlane {

    self.plane = [SKSpriteNode spriteNodeWithImageNamed:kPlane];
    self.plane.xScale = 0.6;
    self.plane.yScale = 0.6;
    self.plane.position = CGPointMake(self.frame.size.width + self.plane.size.width, self.size.height - 75);
    [self addChild:self.plane];
    
    SKAction *planePath = [SKAction moveToX:0 duration:4];
    SKAction* resetPlanePostion = [SKAction moveByX:self.frame.size.width + self.plane.size.width*2 y:0 duration:0];
    SKAction *movePlaneForEver = [SKAction repeatActionForever:[SKAction sequence:@[planePath, resetPlanePostion]]];
    [self.plane runAction:[SKAction sequence:@[movePlaneForEver]]];
}

- (void)setupParachutist {
    
    SKSpriteNode *parachutist = [SKSpriteNode spriteNodeWithImageNamed:kParachutist];
    parachutist.xScale = 0.6;
    parachutist.yScale = 0.6;
    parachutist.position = self.plane.position;
    parachutist.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(parachutist.frame.size.width/2, parachutist.frame.size.height/2)];
    parachutist.physicsBody.dynamic = YES;
    parachutist.physicsBody.affectedByGravity = NO;
    parachutist.physicsBody.categoryBitMask = kParachutistCategory;
    parachutist.physicsBody.contactTestBitMask = kBoatCategory;
    parachutist.physicsBody.collisionBitMask = 0x0;
    
    [self insertChild:parachutist atIndex:1];
    
    int duration = [self durationDependingLevel];
    SKAction *parachutistFadeIn = [SKAction fadeInWithDuration:0.1];
    SKAction *parachutistJump = [SKAction moveTo:CGPointMake(parachutist.position.x, self.boat.position.y - 30) duration:duration];
    SKAction *parachutistFadeOut = [SKAction fadeOutWithDuration:0.18];
    
    
    [parachutist runAction:[SKAction sequence:@[parachutistFadeIn, parachutistJump, parachutistFadeOut, ]] completion:^{
        
        SKAction *paraChutistRemove = [SKAction removeFromParent];
        [parachutist runAction:[SKAction sequence:@[paraChutistRemove]]];
        
        [self parachutistDrown];
    }];
    
}

#pragma mark - Scene Update

- (void)update:(NSTimeInterval)currentTime {
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    //Value to make Randomic jump on X-asis
    double val = ((double)(arc4random() % 5) / 5) + 0.9;
    if (self.lastSpawnTimeInterval > val && [self planeIsFlyingInTheScreen]) {
        self.lastSpawnTimeInterval = 0;
        [self setupParachutist];
    }
}

- (void)updateScore {
    self.score += 10;
    self.scoreLabelNode.text = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"score", nil), self.score];
}

- (void)updateLives {
    self.lives --;
    self.livesLabelNode.text = [NSString stringWithFormat:@"%d", self.lives];
}

#pragma mark - User Tap Helpers

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchedPoint = [touch locationInNode:self];
    SKAction *actionMove = [SKAction moveTo:CGPointMake(touchedPoint.x, self.boat.position.y) duration:0.2];
    [self.boat runAction:actionMove];
    
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKAction *paraChutistRemove = [SKAction removeFromParent];
    [contact.bodyB.node runAction:[SKAction sequence:@[paraChutistRemove]]];
    
    [self updateScore];
}

#pragma mark - Game Helpers

- (BOOL)planeIsFlyingInTheScreen {
    return (self.plane.position.x < (self.frame.size.width - 30) &&
            self.plane.position.x > 30);
}

- (int)durationDependingLevel {
    int minDuration = 0;
    int maxDuration = 0;
    
    if (self.score < kScoreLevel2) {
        minDuration = kMinDurationLevel1;
        maxDuration = kMaxDurationLevel1;
        
    } else if(self.score < kScoreLevel3) {
        minDuration = kMinDurationLevel2;
        maxDuration = kMaxDurationLevel2;
        
    } else if(self.score < kScoreLevel4) {
        minDuration = kMinDurationLevel3;
        maxDuration = kMaxDurationLevel3;
        
    } else {
        minDuration = kMinDurationLevel4;
        maxDuration = kMaxDurationLevel4;
    }
    
    int rangeDuration = maxDuration - minDuration;
    return (arc4random() % rangeDuration) + minDuration;
}

#pragma mark - Game End Helpers

- (void)parachutistDrown {
    [self updateLives];
    
    if ([self isGameOver]) {
        [self endGame];
    }
}

- (BOOL)isGameOver {
    return self.lives == 0;
}

- (void)endGame {
    
    BOOL isHighScore = [self isHighScore];
    [self removeAllChildren];
    [self removeAllActions];
    
    GameOverScene* gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
    [gameOverScene setIsHighScore:isHighScore];
    [self.view presentScene:gameOverScene transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
}

- (BOOL)isHighScore {
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:kHighScore];
    if (self.score > highScore) {
        [[NSUserDefaults standardUserDefaults] setInteger:self.score forKey:kHighScore];
        return YES;
    }
    return NO;
}




@end
