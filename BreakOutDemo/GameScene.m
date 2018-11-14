//
//  GameScene.m
//  BreakOutDemo
//
//  Created by Mircea Popescu on 10/10/18.
//  Copyright © 2018 Mircea Popescu. All rights reserved.
//

#import "GameScene.h"
#import "GameOver.h"
#import "GameWon.h"

static const CGFloat kTrackPointsPerSecond = 1000;

static const uint32_t category_fence     = 0x1 << 3; //0x00000000000000000000000000001000
static const uint32_t category_paddle    = 0x1 << 2; //0x00000000000000000000000000000100
static const uint32_t category_block     = 0x1 << 1; //0x00000000000000000000000000000010
static const uint32_t category_ball      = 0x1 << 0; //0x00000000000000000000000000000001

@interface GameScene() <SKPhysicsContactDelegate>

@property (nonatomic, strong, nullable) UITouch *motivatingTouch;
@property (strong, nonatomic) NSMutableArray *blockFrames;

@end

@implementation GameScene

- (void)didMoveToView:(SKView *)view {
    
    self.name = @"Fence";
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = category_fence;
    self.physicsBody.collisionBitMask = 0x0;
    self.physicsBody.contactTestBitMask = 0x0;
    
    self.physicsWorld.contactDelegate = self;
    
    SKSpriteNode *background = (SKSpriteNode *)[self childNodeWithName:@"Background"];
    background.zPosition = 0; //Bottom of all the things drawn
    background.lightingBitMask = 0x1;
    
    SKSpriteNode *ball1 = [SKSpriteNode spriteNodeWithImageNamed:@"blueball.png"];
    ball1.name = @"Ball1";
    ball1.position = CGPointMake(60, 30);
    ball1.zPosition = 1; //Which layer? -> Layer 1
    ball1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball1.size.width/2];
    ball1.physicsBody.dynamic = YES;
    ball1.physicsBody.friction = 0.0;
    ball1.physicsBody.restitution = 1.0;
    ball1.physicsBody.linearDamping = 0.0;
    ball1.physicsBody.angularDamping = 0.0;
    ball1.physicsBody.allowsRotation = NO;
    ball1.physicsBody.mass = 1.0;
    ball1.physicsBody.velocity = CGVectorMake(300.0, 300.0); // initial velocity
    ball1.physicsBody.affectedByGravity = NO;
    ball1.physicsBody.categoryBitMask = category_ball;
    ball1.physicsBody.collisionBitMask = category_fence | category_ball | category_block | category_paddle;
    ball1.physicsBody.contactTestBitMask = category_fence | category_block;
    ball1.physicsBody.usesPreciseCollisionDetection = YES;
    
    [self addChild:ball1];
    
    //Add a light to the ball(just for fun)
    SKLightNode *light = [SKLightNode new];
    light.categoryBitMask = 0x1;
    light.falloff = 1;
    light.ambientColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    light.lightColor = [UIColor colorWithRed:0.7 green:0.7 blue:1.0 alpha:1.0];
    light.shadowColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    
    [ball1 addChild:light];
    
    SKSpriteNode *ball2 = [SKSpriteNode spriteNodeWithImageNamed:@"blueball.png"];
    ball2.name = @"Ball2";
    ball2.position = CGPointMake(60,75);
    ball2.zPosition = 1;
    ball2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball2.size.width/2];
    ball2.physicsBody.dynamic = YES;
    ball2.physicsBody.friction = 0.0;
    ball2.physicsBody.restitution = 1.0;
    ball2.physicsBody.linearDamping = 0.0;
    ball2.physicsBody.angularDamping = 0.0;
    ball2.physicsBody.allowsRotation = NO;
    ball2.physicsBody.mass = 1.0;
    ball2.physicsBody.velocity = CGVectorMake(300.0, 300.0); // initial velocity
    ball2.physicsBody.affectedByGravity = NO;
    ball2.physicsBody.categoryBitMask = category_ball;
    ball2.physicsBody.collisionBitMask = category_fence | category_ball | category_block | category_paddle;
    ball2.physicsBody.contactTestBitMask = category_fence | category_block;
    ball2.physicsBody.usesPreciseCollisionDetection = YES;
    
    [self addChild:ball2];
    
    
    SKSpriteNode *paddle = [SKSpriteNode spriteNodeWithImageNamed:@"paddle.png"];
    paddle.name = @"paddle";
    paddle.position = CGPointMake(self.size.width/2,50);
    paddle.zPosition = 1;
    paddle.lightingBitMask = 0x1;
    paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(paddle.size.width, paddle.size.height)];
    paddle.physicsBody.dynamic = NO;
    paddle.physicsBody.friction = 0.0;
    paddle.physicsBody.restitution = 1.0;
    paddle.physicsBody.linearDamping = 0.0;
    paddle.physicsBody.angularDamping = 0.0;
    paddle.physicsBody.allowsRotation = NO;
    paddle.physicsBody.mass = 1.0;
    paddle.physicsBody.velocity = CGVectorMake(0.0, 0.0); // no initial velocity
    paddle.physicsBody.categoryBitMask = category_paddle;
    paddle.physicsBody.collisionBitMask = 0x0;
    paddle.physicsBody.contactTestBitMask = category_ball;
    paddle.physicsBody.usesPreciseCollisionDetection = YES;
    
    [self addChild:paddle];
    
    CGPoint ball1Anchor = CGPointMake(ball1.position.x, ball1.position.y);
    CGPoint ball2Anchor = CGPointMake(ball2.position.x, ball2.position.y);
    
    SKPhysicsJointSpring *joint = [SKPhysicsJointSpring jointWithBodyA:ball1.physicsBody bodyB:ball2.physicsBody anchorA:ball1Anchor anchorB:ball2Anchor];
    
    joint.damping = 0.0;
    joint.frequency = 1.5;
    
    [self.scene.physicsWorld addJoint:joint];
    
    self.blockFrames = [NSMutableArray array];
    
    SKTextureAtlas *blockAnimation = [SKTextureAtlas atlasNamed:@"block.atlas"];
    unsigned long numImages = blockAnimation.textureNames.count;
    for (int i=0; i<numImages; i++){
        NSString *textureName = [NSString stringWithFormat:@"block%02d",i];
        SKTexture *temp = [blockAnimation textureNamed:textureName];
        [self.blockFrames addObject:temp];
    }
    
    // Add blocks
    //SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"];
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:self.blockFrames[0]];
    node.scale = 0.2;
    
    CGFloat kBlockWidth = node.size.width;
    CGFloat kBlockHeight = node.size.height;
    CGFloat kBlockHorizSpace = 20.0f;
    int kBlocksPerRow = (self.size.width / (kBlockWidth+kBlockHorizSpace));
    
    // Top row of blocks
    for (int i=0; i < kBlocksPerRow; i++){
        //node = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:self.blockFrames[0]];
        node.scale = 0.2;
        
        node.name = @"Block";
        node.position = CGPointMake(kBlockHorizSpace/2 + kBlockWidth/2 + i*kBlockWidth + i*kBlockHorizSpace,  self.size.height - 100.0);
        node.zPosition = 1;
        node.lightingBitMask = 0x1;
        
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size center:CGPointMake(0, 0)];
        node.physicsBody.dynamic = NO;
        node.physicsBody.friction = 0.0;
        node.physicsBody.restitution = 1.0;
        node.physicsBody.linearDamping = 0.0;
        node.physicsBody.angularDamping = 0.0;
        node.physicsBody.allowsRotation = NO;
        node.physicsBody.mass = 1.0;
        node.physicsBody.velocity = CGVectorMake(0.0, 0.0); // no initial velocity
        node.physicsBody.categoryBitMask = category_block;
        node.physicsBody.collisionBitMask = 0x0;
        node.physicsBody.contactTestBitMask = category_ball;
        node.physicsBody.usesPreciseCollisionDetection = NO;
        
        [self addChild:node];
    }
    
    // Middle row of blocks
    kBlocksPerRow = (self.size.width / (kBlockWidth+kBlockHorizSpace)) -1;
    
    for (int i=0; i < kBlocksPerRow; i++){
        //node = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:self.blockFrames[0]];
        node.scale = 0.2;
        
        node.name = @"Block";
        node.position = CGPointMake(kBlockHorizSpace + kBlockWidth + i*kBlockWidth + i*kBlockHorizSpace,  self.size.height - 100.0 - (2.0 * kBlockHeight));
        node.zPosition = 1;
        node.lightingBitMask = 0x1;
        
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size center:CGPointMake(0, 0)];
        node.physicsBody.dynamic = NO;
        node.physicsBody.friction = 0.0;
        node.physicsBody.restitution = 1.0;
        node.physicsBody.linearDamping = 0.0;
        node.physicsBody.angularDamping = 0.0;
        node.physicsBody.allowsRotation = NO;
        node.physicsBody.mass = 1.0;
        node.physicsBody.velocity = CGVectorMake(0.0, 0.0); // no initial velocity
        node.physicsBody.categoryBitMask = category_block;
        node.physicsBody.collisionBitMask = 0x0;
        node.physicsBody.contactTestBitMask = category_ball;
        node.physicsBody.usesPreciseCollisionDetection = NO;
        
        [self addChild:node];
    }
    
    // Third row of blocks
    kBlocksPerRow = (self.size.width / (kBlockWidth+kBlockHorizSpace));
    
    for (int i=0; i < kBlocksPerRow; i++){
        //node = [SKSpriteNode spriteNodeWithImageNamed:@"block.png"];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:self.blockFrames[0]];
        node.scale = 0.2;
        
        node.name = @"Block";
        node.position = CGPointMake(kBlockHorizSpace/2 + kBlockWidth/2 + i*kBlockWidth + i*kBlockHorizSpace,  self.size.height - 100.0 - (4.0 * kBlockHeight));
        node.zPosition = 1;
        node.lightingBitMask = 0x1;
        
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:node.size center:CGPointMake(0, 0)];
        node.physicsBody.dynamic = NO;
        node.physicsBody.friction = 0.0;
        node.physicsBody.restitution = 1.0;
        node.physicsBody.linearDamping = 0.0;
        node.physicsBody.angularDamping = 0.0;
        node.physicsBody.allowsRotation = NO;
        node.physicsBody.mass = 1.0;
        node.physicsBody.velocity = CGVectorMake(0.0, 0.0); // no initial velocity
        node.physicsBody.categoryBitMask = category_block;
        node.physicsBody.collisionBitMask = 0x0;
        node.physicsBody.contactTestBitMask = category_ball;
        node.physicsBody.usesPreciseCollisionDetection = NO;
        
        [self addChild:node];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    const CGRect touchRegion = CGRectMake(0, 0, self.size.width, self.size.height * 0.3);
    
    for (UITouch *touch in touches) {
        CGPoint p = [touch locationInNode:self];
        
        if (CGRectContainsPoint(touchRegion, p)){
            self.motivatingTouch = touch;
        }
        
    }
    
    [self trackPaddlesToMotivatingTouches];
    
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self trackPaddlesToMotivatingTouches];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([touches containsObject:self.motivatingTouch])
        self.motivatingTouch = nil;
    
}
    
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if([touches containsObject:self.motivatingTouch])
        self.motivatingTouch = nil;
    
}

-(void) trackPaddlesToMotivatingTouches {
    
    SKNode *node = [self childNodeWithName:@"paddle"];
    
    UITouch *touch = self.motivatingTouch;
    if(!touch)
        return;
    
    CGFloat xPos = [touch locationInNode:self].x;
    NSTimeInterval duration = ABS(xPos - node.position.x) / kTrackPointsPerSecond;
    [node runAction:[SKAction moveToX:xPos duration:duration]];
    
}

-(void) didBeginContact:(SKPhysicsContact *)contact{
    
    NSString *nameA = contact.bodyA.node.name;
    NSString *nameB = contact.bodyB.node.name;
    
    
    if(([nameA containsString:@"Block"] && [nameB containsString:@"Ball"]) || ([nameA containsString:@"Ball"] && [nameB containsString:@"Block"])) {
        
        // Figure out which body is exploding
        SKNode *block;
        if([nameA containsString:@"Block"]){
            block = contact.bodyA.node;
        }
        else {
            block = contact.bodyB.node;
        }
        
        // Do the build up
        SKAction *actionAudioRamp = [SKAction playSoundFileNamed:@"sound_block.m4a" waitForCompletion:NO];
        SKAction *actionVisualRamp = [SKAction animateWithTextures:self.blockFrames timePerFrame:0.04f resize:NO restore:NO];
        
        NSString *particleRampPath = [[NSBundle mainBundle] pathForResource:@"ParticleRampUp" ofType:@"sks"];
        SKEmitterNode *particleRamp = [NSKeyedUnarchiver unarchiveObjectWithFile:particleRampPath];
        
        particleRamp.position = CGPointMake(0, 0);
        particleRamp.zPosition = 0;
        
        SKAction *actionParticleRamp = [SKAction runBlock:^{
            [block addChild:particleRamp];
        }];
        
        // Group them together
        SKAction *actionRampSequence = [SKAction group:@[actionAudioRamp, actionParticleRamp, actionVisualRamp]];
        
        SKAction *actionAudioExplode = [SKAction playSoundFileNamed:@"sound_explode.m4a" waitForCompletion:NO];
        NSString *particleExplosionPath = [[NSBundle mainBundle] pathForResource:@"ParticleBlock" ofType:@"sks"];
        SKEmitterNode *particleExplosion = [NSKeyedUnarchiver unarchiveObjectWithFile:particleExplosionPath];
        
        particleExplosion.position = CGPointMake(0, 0);
        particleExplosion.zPosition = 2;
        
        SKAction *actionParticleExplosion = [SKAction runBlock:^{
            [block addChild:particleExplosion];
        }];
        
        SKAction *actionRemoveBlock = [SKAction removeFromParent];
        
        SKAction *actionExplodeSequence = [SKAction sequence:@[actionAudioExplode, actionParticleExplosion, [SKAction fadeOutWithDuration:1]]];
        
        // Check if you won the game, no more blocks remaining
        SKAction *checkGameWon = [SKAction runBlock:^{
            BOOL anyBlocksRemaining = ([self childNodeWithName:@"Block"] != nil);
            if (!anyBlocksRemaining){
                SKView *skView = (SKView *)self.view;
                [self removeFromParent];
                
                //Create and COnfigure the Scene
                GameWon *scene = [GameWon nodeWithFileNamed:@"GameWon"];
                scene.scaleMode = SKSceneScaleModeAspectFit;
                
                //Present the scene
                [skView presentScene:scene];
                
            }
        }];
        [block runAction:[SKAction sequence:@[actionRampSequence,actionExplodeSequence,actionRemoveBlock,checkGameWon]]];
    }
    else if (([nameA containsString:@"Ball"] && [nameB containsString:@"paddle"]) || ([nameA containsString:@"paddle"] && [nameB containsString:@"Ball"])) {
        SKAction *paddleAudio = [SKAction playSoundFileNamed:@"sound_paddle.m4a" waitForCompletion:NO];
        [self runAction:paddleAudio];
    }
    else if(([nameA containsString:@"Fence"] && [nameB containsString:@"Ball"]) || ([nameA containsString:@"Ball"] && [nameB containsString:@"Fence"])) {
        SKAction *fenceAudio = [SKAction playSoundFileNamed:@"sound_wall.m4a" waitForCompletion:NO];
        [self runAction:fenceAudio];
        
        // Figure out which ball hit the fence
        SKNode *ball;
        if([nameA containsString:@"Ball"]){
            ball = contact.bodyA.node;
        }
        else {
            ball = contact.bodyB.node;
        }
        
        // You missed the ball - Game Over!
        if(contact.contactPoint.y < 10){
            
            SKAction *actionAudioExplode = [SKAction playSoundFileNamed:@"sound_explode.m4a" waitForCompletion:NO];
            
            NSString *particleExplosionPath = [[NSBundle mainBundle] pathForResource:@"ParticleBlock" ofType:@"sks"];
            SKEmitterNode *particleExplosion = [NSKeyedUnarchiver unarchiveObjectWithFile:particleExplosionPath];
            
            particleExplosion.position = CGPointMake(0, 0);
            particleExplosion.zPosition = 2;
            particleExplosion.targetNode = self;
            
            SKAction *actionParticleExplosion = [SKAction runBlock:^{
                [ball addChild:particleExplosion];
            }];
            
            SKAction *actionRemoveBall = [SKAction removeFromParent];
            
            SKAction *switchScene =[SKAction runBlock:^{
                SKView *skView = (SKView *)self.view;
                [self removeFromParent];
                
                //Create and Configure the Scene
                GameOver *scene = [GameOver nodeWithFileNamed:@"GameOver"];
                scene.scaleMode = SKSceneScaleModeAspectFill;
                
                //Present the scene
                [skView presentScene:scene];
            }];
            SKAction *actionExplodeSequence = [SKAction sequence:@[actionAudioExplode, actionParticleExplosion, [SKAction fadeOutWithDuration:1], actionRemoveBall, switchScene]];
            [ball runAction:actionExplodeSequence];
        }
        else {
            SKAction *fenceAudio = [SKAction playSoundFileNamed:@"sound_wall.m4a" waitForCompletion:NO];
            [self runAction:fenceAudio];
        }
    }
    NSLog(@"\nWhat colided? %@ %@",nameA, nameB);
}

// Update function is called at every frame
-(void)update:(NSTimeInterval)currentTime{
    
    static const int kMaxSpeed = 700;
    static const int kMinSpeed = 400;
    
    //Adjust the linear dumping id the call starts moving a little too dast or slow
    SKNode *ball1 = [self childNodeWithName:@"Ball1"];
    SKNode *ball2 = [self childNodeWithName:@"Ball2"];
    
    //float speedball1 = sqrt(ball1.physicsBody.velocity.dx*ball1.physicsBody.velocity.dx + ball1.physicsBody.velocity.dy*ball1.physicsBody.velocity.dy);
    
    float dx = (ball1.physicsBody.velocity.dx + ball2.physicsBody.velocity.dx)/2;
    float dy = (ball1.physicsBody.velocity.dy + ball2.physicsBody.velocity.dy)/2;
    float speed = sqrt(dx*dx+dy*dy);
    
    //if ((speedball1 > kMaxSpeed) || (speed > kMaxSpeed)) {
    if (speed > kMaxSpeed) {
        ball1.physicsBody.linearDamping += 0.1f;
        ball2.physicsBody.linearDamping += 0.1f;
    //} else if ((speedball1 < kMinSpeed) || (speed < kMinSpeed)) {
    } else if (speed < kMinSpeed) {
        ball1.physicsBody.linearDamping -= 0.1f;
        ball2.physicsBody.linearDamping -= 0.1f;
    } else {
        ball1.physicsBody.linearDamping += 0.0f;
        ball2.physicsBody.linearDamping += 0.0f;
    }
    
}
@end
