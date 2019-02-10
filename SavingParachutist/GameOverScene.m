//
//  GameOverScene.m
//  SavingParachutist
//
//  Created by Sebastian Natalevich on 3/7/17.
//  Copyright © 2017 Sebastian Natalevich. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"

static NSString *const kFont        = @"Courier";
static NSString *const kHighScore   = @"HighScore";


@interface GameOverScene ()

@property(nonatomic) BOOL isHighScore;

@end

@implementation GameOverScene

#pragma mark - Scene Setup and Content Creation

- (void)didMoveToView:(SKView *)view
{
    [self createContent];
}

- (void)createContent
{
    if (self.isHighScore) {
        SKLabelNode* newHighScoreLabel = [SKLabelNode labelNodeWithFontNamed:kFont];
        newHighScoreLabel.fontSize = 30;
        newHighScoreLabel.fontColor = [SKColor whiteColor];
        NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:kHighScore];
        newHighScoreLabel.text = [NSString stringWithFormat:@"%@%ld",NSLocalizedString(@"newHighScore", nil) , (long)highScore];
        newHighScoreLabel.position = CGPointMake(self.size.width/2, 3.0 / 4.0 * self.size.height);
        [self addChild:newHighScoreLabel];

    }
    
    SKLabelNode* gameOverLabel = [SKLabelNode labelNodeWithFontNamed:kFont];
    gameOverLabel.fontSize = 50;
    gameOverLabel.fontColor = [SKColor whiteColor];
    gameOverLabel.text = NSLocalizedString(@"gameOver", nil);
    gameOverLabel.position = CGPointMake(self.size.width/2, 2.0 / (3.0 + self.isHighScore) * self.size.height);
    [self addChild:gameOverLabel];
    
    SKLabelNode* tapLabel = [SKLabelNode labelNodeWithFontNamed:kFont];
    tapLabel.fontSize = 25;
    tapLabel.fontColor = [SKColor whiteColor];
    tapLabel.text = NSLocalizedString(@"playAgain", nil);
    tapLabel.position = CGPointMake(self.size.width/2, gameOverLabel.frame.origin.y - gameOverLabel.frame.size.height - 40);
    [self addChild:tapLabel];
}

#pragma mark - User Tap Helpers

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    GameScene* gameScene = [[GameScene alloc] initWithSize:self.size];
    gameScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:gameScene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
}

#pragma mark - Private Setters

- (void)setIsHighScore:(BOOL)isHighScore {
    _isHighScore = isHighScore;
}

@end

