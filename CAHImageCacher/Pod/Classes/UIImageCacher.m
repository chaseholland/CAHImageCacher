//
//  UIImageCacher.m
//
//  Created by Chase Holland on 7/12/11.
//  Copyright 2015 Chase Holland. All rights reserved.
//

#import "UIImageCacher.h"
#import "UIImage+AutoMimeType.h"

@interface UIImageCacher()

@property (nonatomic, retain) NSMutableDictionary* imageCacheDictionary;
@property (nonatomic,retain) NSMutableSet* cacheQueue;

+ (NSString*) filePathAtURL:(NSString*)url;
+ (void) setImage:(UIImage*)image inImageView:(UIImageView*)imageView viewToRefresh:(UIView*)view;

@end

static UIImageCacher* s_cacher;

@implementation UIImageCacher

@synthesize imageCacheDictionary;
@synthesize cacheQueue;

+ (UIImageCacher*) sharedCacher
{
	if (!s_cacher) {
		s_cacher = [[UIImageCacher alloc] init];
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
	return [[UIImageCacher applicationDocumentsDirectory] stringByAppendingPathComponent: filename];
}

#pragma mark -
#pragma mark Methods

- (void) removeCachedImageAtURL:(NSString*)url
{
	if (!url)
		return;
	
	[self.imageCacheDictionary removeObjectForKey:url];
	
	NSString* path = [UIImageCacher filePathAtURL:url];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		NSError* error = nil;
		[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
		if (error)
			NSLog(@"<%@> Error at: => %s error:%@", NSStringFromClass([UIImageCacher class]), __PRETTY_FUNCTION__, error.localizedDescription);
	}

}

- (void) cacheImage:(UIImage*)image atLocation:(NSString *)imageURLString
{
	
	if (!image || !imageURLString)
	{
		NSLog(@"Error: Unable to cache image! Either the image or urlstring was nil -- image: %@ url %@", image, imageURLString);
		return;
	}
	
	[self.imageCacheDictionary setObject:image forKey:imageURLString];
	
	// Generate a unique path to a resource representing the image you want
	NSString *uniquePath = [UIImageCacher filePathAtURL:imageURLString];
	
	// Check for file existence
	if(![[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
	{
		// The file doesn't exist, we should get a copy of it
		
		// Is it PNG or JPG/JPEG?
		// Running the image representation function writes the data from the image to a file
		NSString* mimeType = [image mimeType];
		if ([mimeType isEqualToString:@"image/jpeg"])
		{
			[UIImageJPEGRepresentation(image, 100) writeToFile: uniquePath atomically: YES];
		}
		else
		{
			[UIImagePNGRepresentation(image) writeToFile: uniquePath atomically: YES];
		}
		
	}
}

- (UIImage *) getCachedImage: (NSString *) ImageURLString
{
	if ([self.imageCacheDictionary objectForKey:ImageURLString])
		return self.imageCacheDictionary[ImageURLString];
	
	NSString *uniquePath = [UIImageCacher filePathAtURL:ImageURLString];
	UIImage *image = nil;
	
	// Check for a cached version
	if([[NSFileManager defaultManager] fileExistsAtPath: uniquePath])
	{
		image = [UIImage imageWithContentsOfFile: uniquePath];
		if (image)
			[self.imageCacheDictionary setObject:image forKey:ImageURLString];

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
	UIImageCacher* cacher = [UIImageCacher sharedCacher];
	
	if (!string)
		string = [NSString stringWithFormat:@"%p", imageView];
	
	__block UIImage* img = [s_cacher getCachedImage:string];
	if (img)
	{
		[UIImageCacher setImage:img inImageView:imageView viewToRefresh:view];
		[s_cacher.cacheQueue removeObject:string];
		
		if (completion)
			completion();
		return;
	}
	
	[UIImageCacher setImage:altImage inImageView:imageView viewToRefresh:view];
	
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
		if (![s_cacher.cacheQueue containsObject:string]) {
			img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:string]]];
			[cacher cacheImage:img atLocation:string];
		}
		else {
			[cacher.cacheQueue addObject:string];
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (img)
			{
				[UIImageCacher setImage:img inImageView:imageView viewToRefresh:view];
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
