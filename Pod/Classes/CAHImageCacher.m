//
//  CAHImageCacher.m
//
//  Created by Chase Holland on 7/12/11.
//  Copyright (c) 2015 Chase Holland. All rights reserved.
//

#import "CAHImageCacher.h"
#import "UIImage+AutoMimeType.h"

@interface CAHImageCacher()

@property (nonatomic, retain) NSMutableDictionary* imageCacheDictionary;
@property (nonatomic,retain) NSMutableSet* cacheQueue;

+ (NSString*) filePathAtURL:(NSString*)url;
+ (void) setImage:(UIImage*)image inImageView:(UIImageView*)imageView viewToRefresh:(UIView*)view;

@end

static CAHImageCacher* s_cacher;

@implementation CAHImageCacher

@synthesize imageCacheDictionary;
@synthesize cacheQueue;

+ (CAHImageCacher*) sharedCacher
{
	if (!s_cacher) {
		s_cacher = [[CAHImageCacher alloc] init];
		s_cacher.imageCacheDictionary = [[NSMutableDictionary alloc] init];
		s_cacher.cacheQueue = [[NSMutableSet alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:s_cacher queue:nil
													  usingBlock:^(NSNotification *notif) {
														  [s_cacher.imageCacheDictionary removeAllObjects];
													  }];
	}
	return s_cacher;
}

#pragma mark -
#pragma mark NSObject

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:s_cacher];
}

#pragma mark -
#pragma mark Private

// from http://stackoverflow.com/questions/5712527/how-to-detect-total-available-free-disk-space-on-the-iphone-ipad-device
- (uint64_t)freeDiskspace
{
	uint64_t totalSpace = 0;
	uint64_t totalFreeSpace = 0;
	
	__autoreleasing NSError *error = nil;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
	
	if (dictionary) {
		NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
		NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
		totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
		totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
		NSLog(@"Disk Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
	} else {
		NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %d", [error domain], (int)[error code]);
	}
	
	return totalFreeSpace;
}

+ (NSString *) applicationDocumentsDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	return basePath;
}

+ (NSString*) filePathAtURL:(NSString*)url
{
	if (!url)
		return nil;
	
	// Generate a unique path to a resource representing the image you want; must clean up for reserved characters
	NSString *filename = [[url stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""];
	return [[CAHImageCacher applicationDocumentsDirectory] stringByAppendingPathComponent: filename];
}

#pragma mark -
#pragma mark Methods

+ (void) removeCachedImageAtURL:(NSString*)url
{
	if (!url)
		return;
	
	[[CAHImageCacher sharedCacher].imageCacheDictionary removeObjectForKey:url];
	
	NSString* path = [CAHImageCacher filePathAtURL:url];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		NSError* error = nil;
		[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
		if (error)
			NSLog(@"<%@> Error at: => %s error:%@", NSStringFromClass([CAHImageCacher class]), __PRETTY_FUNCTION__, error.localizedDescription);
	}

}

+ (void) cacheImage:(UIImage*)image atLocation:(NSString *)imageURLString
{
	
	if (!image || !imageURLString)
	{
		NSLog(@"Error: Unable to cache image! Either the image or urlstring was nil -- image: %@ url %@", image, imageURLString);
		return;
	}
	
	[[CAHImageCacher sharedCacher].imageCacheDictionary setObject:image forKey:imageURLString];
	
	// Generate a unique path to a resource representing the image you want
	NSString *uniquePath = [CAHImageCacher filePathAtURL:imageURLString];
	
	// Check for file existence
	if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
	{
		// The file doesn't exist, we should get a copy of it
		
		// Is it PNG or JPG/JPEG?
		// Running the image representation function writes the data from the image to a file
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
			NSString* mimeType = [image mimeType];
			if ([mimeType isEqualToString:@"image/jpeg"])
			{
				[UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
			}
			else
			{
				[UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
			}
		});
	}
}

+ (UIImage *) getCachedImage: (NSString *) ImageURLString
{
	if ([[CAHImageCacher sharedCacher].imageCacheDictionary objectForKey:ImageURLString])
		return [CAHImageCacher sharedCacher].imageCacheDictionary[ImageURLString];
	
	NSString *uniquePath = [CAHImageCacher filePathAtURL:ImageURLString];
	UIImage *image = nil;
	
	// Check for a cached version
	if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
	{
		image = [UIImage imageWithContentsOfFile: uniquePath];
		if (image)
			[[CAHImageCacher sharedCacher].imageCacheDictionary setObject:image forKey:ImageURLString];

	}
	
	return image;
}

+ (void) asyncLoadImageIntoImageView:(UIImageView*)imageView imageURLString:(NSString*)string altImage:(UIImage*)altImage
{
	imageView.image = altImage;
	[self asyncLoadImageIntoImageView:imageView imageURLString:string altImage:altImage viewToRefresh:nil];
}

+ (void) asyncLoadImageIntoImageView:(UIImageView*)imageView imageURLString:(NSString*)string altImage:(UIImage*)altImage viewToRefresh:(UIView*)view
{
	[self asyncLoadImageIntoImageView:imageView imageURLString:string altImage:altImage viewToRefresh:view completion:NULL];
}

+ (void) asyncLoadImageIntoImageView:(UIImageView*)imageView imageURLString:(NSString*)string altImage:(UIImage*)altImage viewToRefresh:(UIView*)view completion:(void (^)(void))completion
{
	CAHImageCacher* cacher = [CAHImageCacher sharedCacher];
	
	if (!string)
		string = [NSString stringWithFormat:@"%p", imageView];
	
	__block UIImage* img = [CAHImageCacher getCachedImage:string];
	if (img)
	{
		[CAHImageCacher setImage:img inImageView:imageView viewToRefresh:view];
		[s_cacher.cacheQueue removeObject:string];
		
		if (completion)
			completion();
		return;
	}
	
	[CAHImageCacher setImage:altImage inImageView:imageView viewToRefresh:view];
	
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
		if (![s_cacher.cacheQueue containsObject:string]) {
			img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:string]]];
			[CAHImageCacher cacheImage:img atLocation:string];
		}
		else {
			[cacher.cacheQueue addObject:string];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (img)
			{
				[CAHImageCacher setImage:img inImageView:imageView viewToRefresh:view];
			}
			[s_cacher.cacheQueue removeObject:string];
			if (completion)
				completion();
		});
	});
}

+ (void) setImage:(UIImage*)image inImageView:(UIImageView*)imageView viewToRefresh:(UIView*)view
{
	void (^code) (void) = ^void (void) {
		imageView.image = image;
		[view setNeedsLayout];
		
	};
	if ([[NSThread currentThread] isEqual:[NSThread mainThread]])
	{
		code();
	}
	else
	{
		dispatch_sync(dispatch_get_main_queue(), ^{
			code();
		});
	}
	
	
}

@end
