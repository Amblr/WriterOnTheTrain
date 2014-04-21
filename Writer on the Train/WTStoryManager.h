//
//  WTContentManager.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 28/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class L1Scenario;
@import CoreLocation;
@class WTJourney;
@class WTRealLocationManager;
#import "WTContentBlob.h"
#import "WTLocationManager.h"

@protocol WTStoryManagerDelegate <NSObject>

-(void) chooseStationRequest;
-(BOOL) displayContent:(WTContentBlob*) content;
-(void) locationUpdate:(CLLocation*) location;

@end

@interface WTStoryManager : NSObject<CLLocationManagerDelegate, WTLocationManagerDelegate>
{
    // General properties
    WTLocationManager * locationManager;
    id<WTStoryManagerDelegate> delegate;

    // Info about current journey
    BOOL haveShownContentOnThisJourney;
    

    // Content management
    L1Scenario * scenario;
    NSDictionary * nodes;
    
    // Sequencing and selection
    CLLocationCoordinate2D homeCoordinate;
    CLLocationCoordinate2D workCoordinate;
    
    // This journey
    WTJourney * journey;

    NSMutableArray * contentBlobs;
    NSMutableDictionary * blobStatus;
    NSMutableSet * playedBlobs;
    
    WTContentBlob * scheduledContentBlob;
    
    // Some fake information
    NSDate * fakeDate;
    WTTravelDirection fakeDirectionOfTravel;
    


}
// This class keeps track of the progress through the journey
// Is informed when location nodes are triggered
// Manually triggers after a certain length of time

// It asks its sequencer for what content to use
// Trigger the display of the information

// At the start of the journey:
 // switch on the location updates at low res
 // start a timer to check them at high res every 10 minutes

-(BOOL) startJourney;
-(void) endJourney;
-(void) displayContent:(WTContentBlob*) content;
@property (retain) id delegate;

//-(WTContentBlob*) validContentMatchingName:(NSString*)name atCoordinate:(CLLocationCoordinate2D) coordinate;
//-(WTContentBlob*) nextValidContentAtCoordinate:(CLLocationCoordinate2D) coordinate;
-(NSInteger) contentCount;
-(NSString*) titleForContentAtIndex:(NSInteger) index;
-(WTContentBlob*) contentAtIndex:(NSInteger) index;
-(void) displayContentFromBackground:(NSDictionary*) info;
-(BOOL) contentAtIndexIsAvailable:(NSInteger) index;
-(void) locationUpdate:(CLLocation*) location;
-(WTContentBlob*) nextBlobFrom:(WTContentBlob*) blob;
-(WTContentBlob*) previousBlobFrom:(WTContentBlob*) blob;

-(void) enableBackgroundMode;

@property (retain) WTContentBlob * scheduledContentBlob;

@property (readonly) NSMutableSet * playedBlobs;
@property (assign) CLLocationCoordinate2D homeCoordinate;
@property (assign) CLLocationCoordinate2D workCoordinate;
@property (retain) WTJourney * journey;
@property (retain) NSDate * fakeDate;
@property (assign) WTTravelDirection fakeDirectionOfTravel;

@end
