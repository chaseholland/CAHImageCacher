//
//  CAHImageCacherTests.m
//  CAHImageCacherTests
//
//  Created by Chase Holland on 10/20/2015.
//  Copyright (c) 2015 Chase Holland. All rights reserved.
//

#import "CAHImageCacher.h"

#define FANCY_EXPECTATION() ({XCTestExpectation* expectation; NSString* expectationName = [NSString stringWithFormat:@"%s", __PRETTY_FUNCTION__]; expectation = [self expectationWithDescription:expectationName]; expectation;})

#define FANCY_WAIT(TIME) [self waitForExpectationsWithTimeout:TIME handler:^(NSError* error){NSLog(@"%s Error %@", __PRETTY_FUNCTION__, error.localizedDescription);}];

#define TEST_IMAGE_URL @"https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"

@import XCTest;

@interface CAHImageCacher(TestPrivate)

- (NSMutableDictionary*) imageCacheDictionary;
+ (CAHImageCacher*) sharedCacher;

@end

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testImageRAMCache
{
	XCTestExpectation* exp = FANCY_EXPECTATION();
	
	[CAHImageCacher asyncLoadImageIntoImageView:nil imageURLString:TEST_IMAGE_URL altImage:nil viewToRefresh:nil completion:^{
		CAHImageCacher* cacher = [CAHImageCacher sharedCacher];
		XCTAssert([cacher.imageCacheDictionary objectForKey:TEST_IMAGE_URL]);
		
		[exp fulfill];
	}];
	
	FANCY_WAIT(30.f);
}

@end

