//
//  WTConfiguration.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 28/12/2013.
//  Copyright (c) 2013 Joe Zuntz. All rights reserved.
//

#ifndef Writer_on_the_Train_WTConfiguration_h
#define Writer_on_the_Train_WTConfiguration_h

#define WT_STORY_URL @"http://amblr.heroku.com/scenarios/5097cc2fc561b50002002fba/stories/5097cdecc561b50002002fe9/"
#define WT_SCENARIO_KEY @"5097cc2fc561b50002002fba"



#define TRAIN_SPEED 10.0 // meters per second
#define DELAY_FOR_NONLOCATION_TRIGGER_MINUTES 10


#define REAL_LOCATION 0

#if (REAL_LOCATION==0)
// Length of a minute in seconds.
// Set to 1.0 for fast mode

#warning Using Fake Location
#define MINUTES 1.0
#else
#define MINUTES 60.0
#endif

#define HIGH_RES_LOCATION_INTERVAL_MINUTES 10

#define LOCATION_SPECIFIC_NODE_SIZE_METERS 2000.0

#define WTDEBUG YES

#ifdef WTDEBUG
#   define WTDEBUGLOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#   define WTDEBUGLOG(...)
#endif

#define FAKE_LOCATION_UPDATE_MINUTES 1.0
#define RADIUS_OF_EARTH_METERS 6378100.0



#endif
