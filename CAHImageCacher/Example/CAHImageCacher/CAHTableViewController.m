//
//  CAHViewController.m
//  CAHImageCacher
//
//  Created by Chase Holland on 10/20/2015.
//  Copyright (c) 2015 Chase Holland. All rights reserved.
//

#import "CAHTableViewController.h"
#import "CAHImageCacher.h"

#define QUERY_URL @"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=national+park+scenery"

@interface CAHTableViewController ()

@property (nonatomic, retain) NSArray* results;

@end

@implementation CAHTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSURL* url = [NSURL URLWithString:QUERY_URL];
	
	NSData* data = [NSData dataWithContentsOfURL:url];
	NSError* error = nil;
	self.results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error][@"responseData"][@"results"];
	
	self.title = @"National Parks";
}

#pragma mark -
#pragma mark UITableViewController

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.results.count;
}

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
	[CAHImageCacher asyncLoadImageIntoImageView:imageView imageURLString:response[@"unescapedUrl"] altImage:nil viewToRefresh:imageView completion:^{
		detailLabel.text = response[@"titleNoFormatting"];
	}];
	

	return cell;
}

@end
