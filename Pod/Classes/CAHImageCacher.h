//
//  CAHImageCacher.m
//
//  Created by Chase Holland on 7/12/11.
//  Copyright (c) 2015 Chase Holland. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CAHImageCacher : NSObject

// Methods

//
/// \brief Removes an image at the specified url from the cache (disk and RAM)
/// \param url string of image to remove
/// \note synchronous
//
+ (void) removeCachedImageAtURL:(NSString*)url;

//
/// \brief Caches an image both in RAM and to disk. There is generally no need to call this directly, unless you wish to cache images without displaying them.
/// \param imageURLString Location to use to cache image or filename
/// \note synchronous
//
+ (void) cacheImage:(UIImage*)image atLocation:(NSString *)imageURLString;

//
/// \brief Retrieves an image from the cache. There is generally no need to call this unless you need to manipulate images without displaying them.
/// \param ImageURLString location or URL of image to retrieve
/// \note synchronous
//
+ (UIImage *) getCachedImage: (NSString *) ImageURLString;


//
/// \brief Async loads an image into an image view
/// \param imageView Image View to load image into
/// \param string string representation of URL to get image from
/// \param altImage image to display while loading or if preferred image cannot be displayed
//
+ (void) asyncLoadImageIntoImageView:(UIImageView*)imageView imageURLString:(NSString*)string altImage:(UIImage*)altImage;

//
/// \brief Async loads an image into an image view
/// \param imageView Image View to load image into
/// \param string string representation of URL to get image from
/// \param altImage image to display while loading or if preferred image cannot be displayed
/// \param view Refresh a view other than the target imageView (calls setNeedsLayout on view)
//
+ (void) asyncLoadImageIntoImageView:(UIImageView*)imageView imageURLString:(NSString*)string altImage:(UIImage*)altImage viewToRefresh:(UIView*)view;

//
/// \brief Async loads an image into an image view
/// \param imageView Image View to load image into
/// \param string string representation of URL to get image from
/// \param altImage image to display while loading or if preferred image cannot be displayed
/// \param view Refresh a view other than the target imageView (calls setNeedsLayout on view)
/// \param completion Callback block for when image is downloaded and displayed
//
+ (void) asyncLoadImageIntoImageView:(UIImageView*)imageView imageURLString:(NSString*)string altImage:(UIImage*)altImage viewToRefresh:(UIView*)view completion:(void (^)(void))completion;

@end
