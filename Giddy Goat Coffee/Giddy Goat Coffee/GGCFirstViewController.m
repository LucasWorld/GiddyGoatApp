//
//  GGCFirstViewController.m
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GGCFirstViewController.h"
#import <Twitter/Twitter.h>
#import <MapKit/MapKit.h>


@interface GGCFirstViewController ()

@end

@implementation GGCFirstViewController

@synthesize updateArray;
@synthesize specialsLabel;

#define CAMERA @"Camera"
#define LIBRARY @"Photo Library"

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
        //get downloads on async thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("status downloader", NULL);
    dispatch_async(downloadQueue, ^{
            //get daily specials from @giddygoatupdate
        [self getStatusData];
        dispatch_async(dispatch_get_main_queue(), ^{
                //update label with daily specials from feed
                [specialsLabel setText:[updateArray objectAtIndex:1]];
        });
    });
    dispatch_release(downloadQueue);
}

- (void)viewDidUnload
{
    [self setSpecialsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - First View Icon Links

- (IBAction)gotoMap:(id)sender {
    NSMutableString *url = [[NSMutableString alloc] init];
    NSInteger versionNumber = [[[UIDevice currentDevice] systemVersion] integerValue];
    if (versionNumber < 6) {
        [url appendString:@"http://maps.google.com/maps?q=704+n+bishop+Ave+suite+2+rolla+mo+65401&ll=37.949807,-91.776859"];
        NSURL *mapUrl = [[NSURL alloc] initWithString:url];
        [[UIApplication sharedApplication] openURL:mapUrl];
    } else {
            //code for ios 6 map integration
        NSLog(@"opening maps app in iOS 6");
        //old code using url replaced with new api for mapkit
        //[url appendString:@"http://maps.apple.com/maps?q=704+n+bishop+Ave+suite+2+rolla+mo+65401"];
        
        //new code using mkmapitem
        MKPlacemark *giddyPlacemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.949807,-91.776859) addressDictionary:nil];
        MKMapItem *giddyLocation = [[MKMapItem alloc] initWithPlacemark:giddyPlacemark];
        giddyLocation.name = @"Giddy Goat Coffee";
        giddyLocation.phoneNumber = @"+15734266750";
        giddyLocation.url = [NSURL URLWithString:@"http://tggch.com"];
        
        //open in iOS6 maps
        [giddyLocation openInMapsWithLaunchOptions:nil];
    }
    //NSURL *mapUrl = [[NSURL alloc] initWithString:url];
    //[[UIApplication sharedApplication] openURL:mapUrl];
}

#pragma mark - Social Integration / Photo Upload

- (IBAction)getPhotoForSharing:(id)sender {
        //create image picker controller
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
        //create action sheet to prompt user with options for pictures
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Send With Photo"
                                                             delegate:self
                                                    cancelButtonTitle:@"No Photo"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
        //set action sheet style
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    
        //if camera is available add that to the popup list of options
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //add button for camera
        [actionSheet addButtonWithTitle:CAMERA];
    }
        //if photo library is available add that to the popup list of options
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            //add button for library
        [actionSheet addButtonWithTitle:LIBRARY];
    }
        //show action sheet
    [actionSheet showInView:self.parentViewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *desired = (NSString *)kUTTypeImage;
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
            //No Photos jump to shareMe
        imageSelected = nil;
        [self shareMe:self];
        return;
    } else if ([choice isEqualToString:CAMERA]) {
            //get photo from camera
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if ([choice isEqualToString:LIBRARY]) {
            //get photo from library
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePicker.allowsEditing = YES;
    imagePicker.mediaTypes = [NSArray arrayWithObject:desired];
    [self.parentViewController presentModalViewController:imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
        //extract image
    imageSelected = [info objectForKey:UIImagePickerControllerEditedImage];
    
        //[self dismissViewControllerAnimated:YES completion:^([self shareMe:self])];
    [self dismissViewControllerAnimated:YES completion:^{[self shareMe:self];}];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];;
}

- (IBAction)shareMe:(id)sender
{
    NSString *textToShare = @"@TGGCHRolla ";
    NSArray *activityItems;
    if (imageSelected) {
        activityItems = @[textToShare, imageSelected];
    } else {
        activityItems = @[textToShare];
    }
    NSInteger versionNumber = [[[UIDevice currentDevice] systemVersion] integerValue];
    if (versionNumber < 6) {
        if ([TWTweetComposeViewController canSendTweet])
            {
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
            [tweetSheet setInitialText:textToShare];
            if (imageSelected) {
                [tweetSheet addImage:imageSelected];
            }
            [self presentModalViewController:tweetSheet animated:YES];
            }
    } else {
            //code for ios 6
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    imageSelected = nil;
}

#pragma mark - status update and cache methods

- (void)getStatusData
{
    NSString *arrayPath;
    arrayPath = [self statusArrayFilePath];
    NSArray *arrayFromFile = [NSArray arrayWithContentsOfFile:arrayPath];
    if (arrayFromFile) {
        NSInteger months;
        NSInteger days;
        [self compareDates:arrayFromFile months_p:&months days_p:&days];
            
        NSLog(@"Months: %d Days: %d", months, days);
        
        if (days > 0 || months > 0) {
                //get fresh feed
            NSLog(@"Getting fresh data");
            [self fetchSpecials];
        } else {
            NSLog(@"Loading cache data");
            updateArray = [[NSMutableArray alloc] initWithContentsOfFile:[self statusArrayFilePath]];
            NSLog(@"Update Array: %@", updateArray);
        }
    } else {
            //if no file on file system yet get fresh feed
            [self fetchSpecials];
    }
}

- (void)fetchSpecials
{
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/user_timeline.xml?screen_name=giddygoatupdate&count=1"];
    
    updateArray = [[NSMutableArray alloc] init];
    
    NSMutableString *updateString = [[NSMutableString alloc] init];
    NSMutableString *dateString = [[NSMutableString alloc] init];
    
    NSData *xmlData = [[NSData alloc] initWithContentsOfURL:url];
        //convert xml to string and dump to log
        //NSString *xmlCheck = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
        //NSLog(@"xmlCheck:\n%@", xmlCheck);
    
    if (xmlData) {
            //tbxml = [[TBXML alloc] initWithXMLData:xmlData];
        tbxml = [[TBXML alloc] initWithURL:url];
        
            //obtain root element
        TBXMLElement * root = tbxml.rootXMLElement;
        if (root) {
            NSLog(@"Got Root Element");
            TBXMLElement * elem_status = [TBXML childElementNamed:@"status" parentElement:root];
            while (elem_status != nil) {
                NSLog(@"elem_status != nil");
                
                TBXMLElement * elem_date = [TBXML childElementNamed:@"created_at" parentElement:elem_status];
                NSString *date = [TBXML textForElement:elem_date];
                NSLog(@"Status Date:  %@", date);
                [dateString appendString:date];
                
                TBXMLElement * elem_text = [TBXML childElementNamed:@"text" parentElement:elem_status];
                NSString *text = [TBXML textForElement:elem_text];
                NSLog(@"Status: %@", text);
                [updateString appendString:text];
                
                elem_status = [TBXML nextSiblingNamed:@"status" searchFromElement:elem_status];
            }
        }
    } else {
            //just in case feed is down
        [dateString appendString:@"2012-01-01 00:00:00 +0000"];
        [updateString appendString:@"No specials listed today. Please check back later."];
    }
    [updateArray addObject:dateString];
    [updateArray addObject:updateString];
    NSLog(@"Saving XML to file system");
    [updateArray writeToFile:[self statusArrayFilePath] atomically:YES];
}

- (void)compareDates:(NSArray *)arrayFromFile months_p:(NSInteger *)months_p days_p:(NSInteger *)days_p
{
        //select date format for string in
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
        //get date from array
    NSDate *dateFromFile = [dateFormatter dateFromString:[arrayFromFile objectAtIndex:0]];
        NSLog(@"File Date:    %@", dateFromFile);
    NSDate *now = [NSDate date];
        NSLog(@"Current Date: %@", now);
        //convert dates to days and months for comparison
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger units = NSMonthCalendarUnit | NSDayCalendarUnit;
        //compare months and days
        //NSDateComponents *comp = [cal components:units fromDate:dateFromFile toDate:now options:0];
    
        //trying manual comparison since this comp failed to see 1 day difference in dates maybe due to times???
    NSDateComponents *nowComps = [cal components:units fromDate:now];
    NSDateComponents *fileComps = [cal components:units fromDate:dateFromFile];
    NSInteger dayComp = [nowComps day] - [fileComps day];
    NSInteger monthComp = [nowComps month] - [fileComps month];
    NSLog(@"Manual; Months: %d Days: %d", monthComp, dayComp);
    
    
        //NSDateComponents *comp = [cal components:units fromDate:now toDate:dateFromFile options:0];
        //save comparison as nsinteger
        //NSLog(@"Months: %d Days: %d", [comp month], [comp day]);
    *months_p = monthComp;
    *days_p = dayComp;
    
    
}

- (NSString *)statusArrayFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
        // Path to save array data
    NSString  *arrayPath = [[paths objectAtIndex:0]
                            stringByAppendingPathComponent:@"status.out"];
    return arrayPath;
}



@end
