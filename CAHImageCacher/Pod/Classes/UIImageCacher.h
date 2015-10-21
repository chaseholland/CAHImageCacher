//
//  UIImageCacher.h
//  Minefield
//
//  Created by Chase Holland on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImageCacher : NSObject

//
/// \brief Returns a the singleton instance of the cacher. Although allocating a variable is also perfectly fine, this singleton interface allows the cacher to persist so writes do not get cancelled.
//
+ (UIImageCacher*) sharedCacher;

// Methods

//
/// \brief Removes an image at the specified url from the cache (disk and RAM)
/// \param url string of image to remove
//
- (void) removeCachedImageAtURL:(NSString*)url;

//
/// \brief Caches an image both in RAM and to disk.
/// \param imageURLString Location to use to cache image or filename
//
- (void) cacheImage:(UIImage*)image atLocation:(NSString *)imageURLString;

//
/// \brief Retrieves an image from the cache.
/// \param ImageURLString location or URL of image to retrieve
//
- (UIImage *) getCachedImage: (NSString *) ImageURLString;


+ (void) asyncLoadImageIntoImageView:(UIImageView*)imageView imageURLString:(NSString*)string altImage:(UIImage*)altImage;
+ (void) asyncLoadImageIntoImageView:(UIImageView*)imageView imageURLString:(NSString*)string altImage:(UIImage*)altImage viewToRefresh:(UIView*)view;
+ (void) asyncLoadImageIntoImageView:(UIImageView*)imageView imageURLString:(NSString*)string altImage:(UIImage*)altImage viewToRefresh:(UIView*)view completion:(void (^)(void))completion;

@end
