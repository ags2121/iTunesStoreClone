//
//  ISDetailsViewController.m
//  iTunesStore
//
//  Created by Alex Silva on 4/25/13.
//  Copyright (c) 2013 Alex Silva. All rights reserved.
//

#import "ISDetailsViewController.h"

@interface ISDetailsViewController ()

@end

@implementation ISDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"app name in dvc: %@", self.appName);
    
    self.textView.text = self.appDescrip;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buyBtnPressed:(id)sender {
}
@end
