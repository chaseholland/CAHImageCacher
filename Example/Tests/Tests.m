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

#define TEST_IMAGE_URL_PNG @"https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"
#define TEST_IMAGE_JPG @"https://upload.wikimedia.org/wikipedia/commons/a/a0/Google_favicon_2012.jpg"

@import XCTest;

@interface CAHImageCacher(TestPrivate)

- (NSMutableDictionary*) imageCacheDictionary;
+ (CAHImageCacher*) sharedCacher;
+ (NSString*) filePathAtURL:(NSString*)url;

@end

@interface Tests : XCTestCase

@property (nonatomic, retain) UIImage* testImage;

@end

@implementation Tests

#pragma mark -
#pragma mark XCTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	
	[CAHImageCacher removeCachedImageAtURL:TEST_IMAGE_URL_PNG];
	
	if (!self.testImage) {
		self.testImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:TEST_IMAGE_URL_PNG]]];
	}
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
	[CAHImageCacher removeCachedImageAtURL:TEST_IMAGE_URL_PNG];
	
    [super tearDown];
}

#pragma mark -
#pragma mark Tests

- (void)testImageRAMCacheViaAsyncLoad
{
	XCTestExpectation* exp = FANCY_EXPECTATION();
	
	[CAHImageCacher asyncLoadImageIntoImageView:nil imageURLString:TEST_IMAGE_URL_PNG altImage:nil viewToRefresh:nil completion:^{
		CAHImageCacher* cacher = [CAHImageCacher sharedCacher];
		XCTAssert([cacher.imageCacheDictionary objectForKey:TEST_IMAGE_URL_PNG]);
		
		[exp fulfill];
	}];
	
	FANCY_WAIT(30.f);
}

- (void) testManualDiskCache {
	[CAHImageCacher cacheImage:self.testImage atLocation:TEST_IMAGE_URL_PNG];
	
	NSString *uniquePath = [CAHImageCacher filePathAtURL:TEST_IMAGE_URL_PNG];
	XCTAssert([[NSFileManager defaultManager] fileExistsAtPath: uniquePath], @"File not cached to disk");
}

- (void) testManualRAMCache {
	[CAHImageCacher cacheImage:self.testImage atLocation:TEST_IMAGE_URL_PNG];
	
	XCTAssert([[CAHImageCacher sharedCacher].imageCacheDictionary objectForKey:TEST_IMAGE_URL_PNG]);
}

- (void) testManualRemove {
	[CAHImageCacher cacheImage:self.testImage atLocation:TEST_IMAGE_URL_PNG];
	[CAHImageCacher removeCachedImageAtURL:TEST_IMAGE_URL_PNG];
	
	XCTAssertFalse([[CAHImageCacher sharedCacher].imageCacheDictionary objectForKey:TEST_IMAGE_URL_PNG]);
	
	NSString *uniquePath = [CAHImageCacher filePathAtURL:TEST_IMAGE_URL_PNG];
	XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath: uniquePath], @"File not cleared from disk");
}

@end

