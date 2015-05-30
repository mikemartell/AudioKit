//
//  AKRingModulatorTests.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 5/22/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKTestCase.h"

#define testDuration 10.0

@interface TestRingModulatorInstrument : AKInstrument
@end

@implementation TestRingModulatorInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSString *filename = [AKManager pathToSoundFile:@"PianoBassDrumLoop" ofType:@"wav"];
        AKFileInput *audio = [[AKFileInput alloc] initWithFilename:filename];
        audio.loop = YES;
        AKMix *mono = [[AKMix alloc] initMonoAudioFromStereoInput:audio];
        
        AKLine *frequency = [[AKLine alloc] initWithFirstPoint:akp(0)
                                                   secondPoint:akp(1000)
                                         durationBetweenPoints:akp(testDuration)];
        
        AKOscillator *oscillator = [AKOscillator oscillator];
        oscillator.frequency = frequency;
        
        AKRingModulator *ringModulator = [[AKRingModulator alloc] initWithInput:mono carrier:oscillator];
        
        [self setAudioOutput:ringModulator];
    }
    return self;
}

@end

@interface AKRingModulatorTests : AKTestCase
@end

@implementation AKRingModulatorTests

- (void)testRingModulator
{
    // Set up performance
    TestRingModulatorInstrument *testInstrument = [[TestRingModulatorInstrument alloc] init];
    [AKOrchestra addInstrument:testInstrument];
    [testInstrument playForDuration:testDuration];
    
    // Render audio output
    NSString *outputFile = [NSString stringWithFormat:@"%@/AKTest-RingModulator.aiff", NSTemporaryDirectory()];
    [[AKManager sharedManager] renderToFile:outputFile forDuration:testDuration];
    
    // Check output
    NSData *nsData = [NSData dataWithContentsOfFile:outputFile];
    NSArray *validMD5s = @[@"54d97ab55d11a42e871ae9cf03809ad0",
                           @"61625a205683185d63d03f3be8796cbc"];
    XCTAssertTrue([validMD5s containsObject:[nsData MD5]]);
}

@end
