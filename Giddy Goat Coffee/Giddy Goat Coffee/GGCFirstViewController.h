//
//  GGCFirstViewController.h
//  Giddy Goat Coffee
//
//  Created by Todd Pickell on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "TBXML.h"

@interface GGCFirstViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray *updateArray;
    TBXML *tbxml;
    UIImagePickerController *imagePicker;
    UIImage *imageSelected;
}

@property (nonatomic)NSMutableArray *updateArray;
@property (weak, nonatomic) IBOutlet UILabel *specialsLabel;
@property (strong, nonatomic)UIImagePickerController *imagePicker;
@property (strong, nonatomic)UIImage *imageSelected;

- (IBAction)gotoMap:(id)sender;

- (IBAction)getPhotoForSharing:(id)sender;


- (IBAction)shareMe:(id)sender;
- (void)getStatusData;
- (void)fetchSpecials;
- (NSString *)statusArrayFilePath;

- (void)compareDates:(NSArray *)arrayFromFile months_p:(NSInteger *)months_p days_p:(NSInteger *)days_p;

@end
