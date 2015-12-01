//
//  ViewController_BSide.m
//  Apparel 1.0
//
//  Created by Aurélien Michon on 16/01/15.
//  Copyright (c) 2015 N_O_R_M_A_L_S. All rights reserved.
//

#import "ViewController_BSide.h"
#import <TwitterKit/TwitterKit.h>
#include "ofApp.h"
#include "user.h"
#include "userTwitterGuestIOS.h"
#include "Globals.h"


//--------------------------------------------------------------
@interface ViewController_BSide ()
@end

//--------------------------------------------------------------
@implementation ViewController_BSide



//--------------------------------------------------------------
- (IBAction)unwindToBSide:(UIStoryboardSegue *)unwindSegue
{
}

//--------------------------------------------------------------
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//--------------------------------------------------------------
- (IBAction)signInWithTwitter:(id)sender
{
	TWTRSession* session = [[Twitter sharedInstance] session];
	
	// Not connected
	if (session == nil)
	{
	  [_btnConnectTwitter setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	  [_btnConnectTwitter setTitle:@"Connecting..." forState:UIControlStateNormal];
	  _btnConnectTwitter.showsTouchWhenHighlighted = NO;

	  [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error)
	  {
		 // http://stackoverflow.com/questions/29120055/how-to-get-profile-url-of-the-logged-in-user-with-twitter-kit-fabric-ios
		 if (![error isEqual:nil])
		 {
			 [self changeUserAndRetrieveInfoUser:session];
		 }
	   
		 [self updateBtnTwitter];
	  }];
	}
	// Connected
	else
	{
		[[Twitter sharedInstance] logOut];
		[self updateBtnTwitter];
	}
}

//--------------------------------------------------------------
- (IBAction)setARModeON:(id)sender
{
	ofApp* pApp = GLOBALS->getApp();
	if (pApp)
	{
		pApp->setARMode(true);
	}
	[self updateLayout];
}

//--------------------------------------------------------------
- (IBAction)setARModeOFF:(id)sender
{
	ofApp* pApp = GLOBALS->getApp();
	if (pApp)
	{
		pApp->setARMode(false);
	}
	[self updateLayout];
}

//--------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    [self.view addGestureRecognizer:tapRecognizer];
    tapRecognizer.delegate = self;

	[self updateLayout];
}

//--------------------------------------------------------------
-(void) updateLayout
{
	ofApp* pApp = GLOBALS->getApp();
	if (pApp)
	{
		// AR
		if (pApp->getARMode())
		{
			[_btnARModeOFF setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
			[_btnARModeON setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
			_btnARModeOFF.showsTouchWhenHighlighted = NO;
			_btnARModeON.showsTouchWhenHighlighted = YES;
		}
		else
		{
			[_btnARModeOFF setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[_btnARModeON setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

			_btnARModeOFF.showsTouchWhenHighlighted = YES;
			_btnARModeON.showsTouchWhenHighlighted = NO;
		}
		
		// Templates buttons
		[_btnTemplate01 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[_btnTemplate02 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
		[_btnTemplate03 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

		int templateIndex = pApp->getTemplateIndexSelected();
		if (templateIndex == 0)	[_btnTemplate01 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		if (templateIndex == 1)	[_btnTemplate02 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		if (templateIndex == 2)	[_btnTemplate03 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	}
 
	// Btn twitter
	[self updateBtnTwitter];
}

//--------------------------------------------------------------
-(void) updateBtnTwitter
{
	[_btnConnectTwitter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	_btnConnectTwitter.showsTouchWhenHighlighted = YES;

	TWTRSession* session = [[Twitter sharedInstance] session];
	if (session != nil)
	{
		[_btnConnectTwitter setTitle:@"Disconnect" forState:UIControlStateNormal];
	}
	else
	{
		[_btnConnectTwitter setTitle:@"Connect" forState:UIControlStateNormal];
	}
}

//--------------------------------------------------------------
-(void) changeUserAndRetrieveInfoUser: (TWTRSession*) session
{
 	NSLog(@"Twitter signed in as -> name = %@ id = %@ ", [session userName],[session userID]);
	ofApp* pApp = GLOBALS->getApp();
	if (pApp)
	{
		pApp->changeUser( [[session userID] UTF8String] );
		
		user* pUser = GLOBALS->getUser();
		if (pUser)
		{
			userTwitterGuestIOS* pTwitterIOS = (userTwitterGuestIOS*) pUser->getService("twitter");
			if (pTwitterIOS) pTwitterIOS->retrieveInfo();
		}
	}
}

//--------------------------------------------------------------
-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

//--------------------------------------------------------------
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField setReturnKeyType:UIReturnKeyDone];
    // Submit Data from done
    //
    // Then close the keyboard
    //[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [textField resignFirstResponder];
    return YES;
}

//--------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------------------------------------------
-(IBAction)selectTemplate01:(id)sender
{
	int templateIndex = GLOBALS->getApp()->getTemplateIndexSelected();
	GLOBALS->getApp()->onTemplateSelected(templateIndex == 0 ? -1 : 0);
	[self updateLayout];
}

//--------------------------------------------------------------
-(IBAction)selectTemplate02:(id)sender
{
	int templateIndex = GLOBALS->getApp()->getTemplateIndexSelected();
	GLOBALS->getApp()->onTemplateSelected(templateIndex == 1 ? -1 : 1);
	[self updateLayout];
}

//--------------------------------------------------------------
-(IBAction)selectTemplate03:(id)sender
{
	int templateIndex = GLOBALS->getApp()->getTemplateIndexSelected();
	GLOBALS->getApp()->onTemplateSelected(templateIndex == 2 ? -1 : 2);
	[self updateLayout];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
