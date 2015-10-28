# CAHImageCacher
Mostly full-featured, asynchronous image cacher with a simple interface. CAHImageCacher asynchronously downloads an image from a URL, caches it to a dictionary, renders it to a UIImageView, and saves it to disk.

CAHImageCacher currently does NOT employ any sort of policy for automatically removing cached images from RAM or from disk. CAHImageCacher DOES purge its in-memory cache of images if a UIApplicationDidReceiveMemoryWarningNotification is triggered. If you need to purge from disk, you may manually delete items by calling:

`+ (void) removeCachedImageAtURL:(NSString*)url;`

As such, CAHImageCacher is fantastic for downloading static images from a server upon initial setup.

Basic Useage
------------

Basic useage is included in the enclosed sample app for using CAHImageCacher to load images into a table view, but the most common use case will be some various of 

`+ (void) asyncLoadImageIntoImageView:(UIImageView*)imageView imageURLString:(NSString*)string altImage:(UIImage*)altImage viewToRefresh:(UIView*)view completion:(void (^)(void))completion;`

or it's simpler variants.

Here is the sample from the sample app:

```
	// load image into image view from web
	[CAHImageCacher asyncLoadImageIntoImageView:imageView imageURLString:response[@"unescapedUrl"] altImage:nil viewToRefresh:imageView completion:^{
		// Set the description once loading is complete
		detailLabel.text = response[@"titleNoFormatting"];
	}];
```
	
Or, in the greater context of loading an image into a table view cell:

```
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ImageCell"];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	__weak UIImageView* imageView = (UIImageView*)[cell.contentView viewWithTag:100];
	__weak UILabel* detailLabel = (UILabel*)[cell.contentView viewWithTag:101];
	
	NSDictionary* response = self.results[indexPath.row];
	detailLabel.text = @"Loading";
	
	// load image into image view from web
	[CAHImageCacher asyncLoadImageIntoImageView:imageView imageURLString:response[@"unescapedUrl"] altImage:nil viewToRefresh:imageView completion:^{
		detailLabel.text = response[@"titleNoFormatting"];
	}];
	

	return cell;
}
```
