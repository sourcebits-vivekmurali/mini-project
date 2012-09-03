//
//  StoryViewController.m
//  ThreeLittlePigs
//
//  Created by Vivek Murali on 30/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StoryViewController.h"

@implementation StoryViewController

@synthesize storyScrollView;
@synthesize scenes = _scenes;
@synthesize model = _model;
@synthesize allScenesImagesAndIDs = _allScenesImagesAndIDs;
@synthesize modelDelegate = _modelDelegate;
@synthesize audioPlayer = _audioPlayer;
@synthesize previousSceneScrollPoint = _previousSceneScrollPoint;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	//Get the scenes using appdelegate instance 
	TLPAppDelegate *appDelegate = (TLPAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.modelDelegate = appDelegate;
	self.model = [self.modelDelegate modelSharedInstance];
	
	// Set scrollview parameters
	self.storyScrollView.contentSize = CGSizeMake(1024 * self.model.scenes.count, 768);
	self.storyScrollView.clipsToBounds = YES;
	self.storyScrollView.delegate = self;
	
	//Initialize
	self.allScenesImagesAndIDs = [NSMutableArray array];
	self.previousSceneScrollPoint = CGPointMake(0, 0);
	int loopIndex = 0;
	
	//Iterate through all scenes
	for (NSDictionary *scene in self.model.scenes)
	{
		ImageAndID *imageAndID = [[ImageAndID alloc] init];
		imageAndID.imageViews = [NSMutableArray array];
		imageAndID.identifiers = [NSMutableArray array];
		
		//draw Images
		NSDictionary *objectsDictionary = [scene objectForKey:@"Objects"];
		
		id temp = [objectsDictionary objectForKey:@"Image"];
		if ([temp isKindOfClass:[NSDictionary class]])
		{
			NSString *fileName = [temp objectForKey:@"-fileName"];
			NSString *identifier = [temp objectForKey:@"-id"];
			
			UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[fileName substringToIndex:fileName.length-4] ofType:@"png"]];
			int x = [[temp objectForKey:@"-x"] intValue] + (1024 * loopIndex);
			int y = [[temp objectForKey:@"-y"] intValue];
			NSString *visible = [temp objectForKey:@"-visible"];
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, image.size.width, image.size.height)];
			if (![visible isEqualToString:@"true"])
			{
				imageView.hidden = YES;
			}
			imageView.image = image;
			[self.storyScrollView addSubview:imageView];
			
			[imageAndID.imageViews addObject:imageView];
			[imageAndID.identifiers addObject:identifier];
		}
		else if ([temp isKindOfClass:[NSArray class]])
		{
			for (NSDictionary *imageDataArray in temp)
			{
				NSString *fileName = [imageDataArray objectForKey:@"-fileName"];
				NSString *identifier = [imageDataArray objectForKey:@"-id"];
				
				UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[fileName substringToIndex:fileName.length-4] ofType:@"png"]];
				int x = [[imageDataArray objectForKey:@"-x"] intValue] + (1024 * loopIndex);
				int y = [[imageDataArray objectForKey:@"-y"] intValue];
				NSString *visible = [imageDataArray objectForKey:@"-visible"];
				
				UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, image.size.width, image.size.height)];
				if (![visible isEqualToString:@"true"])
				{
					imageView.hidden = YES;
				}
				imageView.image = image;
				
				[self.storyScrollView addSubview:imageView];
				
				[imageAndID.imageViews addObject:imageView];
				[imageAndID.identifiers addObject:identifier];
			}
		}// End of draw images
		
		
		//Add buttons
		UIButton *next = [[UIButton alloc] initWithFrame:CGRectMake(932 + (1024 * loopIndex), 660, 100, 100)];
		[next setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"next_ipad" ofType:@"png"]] forState:UIControlStateNormal];

		
		UIButton *prev = [[UIButton alloc] initWithFrame:CGRectMake(-10 + (1024 * loopIndex), 660, 100, 100)];
		[prev setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"back_ipad" ofType:@"png"]] forState:UIControlStateNormal];
		
		[next addTarget:self action:@selector(goToNextPage:) forControlEvents:UIControlEventTouchUpInside];
		[prev addTarget:self action:@selector(goToPrevPage:) forControlEvents:UIControlEventTouchUpInside];

		if (loopIndex == 0)
		{
			prev.enabled = NO;
		}
		if (loopIndex == self.model.scenes.count-1)
		{
			next.enabled = NO;
		}
		[self.storyScrollView addSubview:next];
		[self.storyScrollView addSubview:prev];
		
		
		//cycle animations
		NSInteger sceneIndex = loopIndex;
		ImageAndID *sceneImagesAndIdentifiers = imageAndID;
		
		id cycle = [objectsDictionary objectForKey:@"Cycle"];
		if ([cycle isKindOfClass:[NSDictionary class]])
		{
			NSMutableArray *cycleImagesArray = [NSMutableArray array];
			NSArray *frame = [cycle objectForKey:@"Frame"];
			NSString *identifier = [cycle objectForKey:@"-id"];
			for (NSDictionary *imageFile in frame)
			{
				NSString *fileName = [imageFile objectForKey:@"-fileName"];
				UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[fileName substringToIndex:fileName.length-4] ofType:@"png"]];
				[cycleImagesArray addObject:image];
			}
			
			int x = [[cycle objectForKey:@"-x"] intValue] + (1024 * sceneIndex);
			int y = [[cycle objectForKey:@"-y"] intValue];
			int width = 0,height = 0;
			if ([cycleImagesArray objectAtIndex:0])
			{
				UIImage *firstImage = [cycleImagesArray objectAtIndex:0];
				width = firstImage.size.width;
				height = firstImage.size.height;
			}
			UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
			
			if (x >= (1024 * (sceneIndex + 1)) ||  x <= (1024 * sceneIndex))
			{
				imageView.hidden = YES;
			}
			
			imageView.animationImages = cycleImagesArray;
			imageView.animationDuration = 1.0;
			[imageView startAnimating];
			
			[self.storyScrollView addSubview:imageView];
			
			[sceneImagesAndIdentifiers.imageViews addObject:imageView];
			[sceneImagesAndIdentifiers.identifiers addObject:identifier];
		}
		
		else if([cycle isKindOfClass:[NSArray class]])
		{
			for (NSDictionary *animationDictionary in cycle)
			{
				NSMutableArray *cycleImagesArray = [NSMutableArray array];
				NSArray *frame = [animationDictionary objectForKey:@"Frame"];
				NSString *identifier = [animationDictionary objectForKey:@"-id"];
				for (NSDictionary *imageFile in frame)
				{
					NSString *fileName = [imageFile objectForKey:@"-fileName"];
					UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[fileName substringToIndex:fileName.length-4] ofType:@"png"]];
					[cycleImagesArray addObject:image];
				}
				
				int x = [[animationDictionary objectForKey:@"-x"] intValue] + (1024 * sceneIndex);
				int y = [[animationDictionary objectForKey:@"-y"] intValue];
				int width = 0,height = 0;
				if ([cycleImagesArray objectAtIndex:0])
				{
					UIImage *firstImage = [cycleImagesArray objectAtIndex:0];
					width = firstImage.size.width;
					height = firstImage.size.height;
				}
				UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
				
				if (x >= (1024 * (sceneIndex + 1)) ||  x <= (1024 * sceneIndex))
				{
					imageView.hidden = YES;
				}
				
				imageView.animationImages = cycleImagesArray;
				imageView.animationDuration = 1.0;
				[imageView startAnimating];
				
				[self.storyScrollView addSubview:imageView];
				
				[sceneImagesAndIdentifiers.imageViews addObject:imageView];
				[sceneImagesAndIdentifiers.identifiers addObject:identifier];
			}
		}//End of cycle animations
		
		[self.allScenesImagesAndIDs addObject:imageAndID];
		loopIndex++;
	}
}

- (void)goToNextPage:(UIButton *)button
{
	CGPoint point = self.storyScrollView.contentOffset;
	[self.storyScrollView scrollRectToVisible:CGRectMake(point.x + 1024, point.y, 1024, 768) animated:YES];
}

- (void)goToPrevPage:(UIButton *)button
{
	CGPoint point = self.storyScrollView.contentOffset;
	[self.storyScrollView scrollRectToVisible:CGRectMake(point.x - 1024, point.y, 1024, 768) animated:YES];
}

- (void)doAnimationsForSceneWithIndex:(NSInteger)sceneIndex
{
	if(self.audioPlayer.isPlaying)
	{
		[self.audioPlayer stop];
	}
	
	ImageAndID *sceneImagesAndIdentifiers = [self.allScenesImagesAndIDs objectAtIndex:sceneIndex];
	NSDictionary *scene = [self.model.scenes objectAtIndex:sceneIndex];
	
	NSDictionary *actions = [scene objectForKey:@"Actions"];
	
	//Get the audio file and play
	NSDictionary *audioDictionary = [scene objectForKey:@"Audio"];
	NSString *fileName = [audioDictionary objectForKey:@"-fileName"];
	fileName = [fileName substringToIndex:fileName.length -4];
	NSData *fileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"m4a"]];
	self.audioPlayer = [[AVAudioPlayer alloc] initWithData:fileData error:nil];
	[self.audioPlayer play];
	
	
	//move animations
	id move = [actions objectForKey:@"Move"];
	if ([move isKindOfClass:[NSDictionary class]])
	{
		NSString *target = [move objectForKey:@"-target"];
		int toX = [[move objectForKey:@"-toX"] intValue] + (1024 * sceneIndex);
		int toY = [[move objectForKey:@"-toY"] intValue];
		int duration = [[move objectForKey:@"-duration"] intValue];
		duration /= 1000;
		int delay = 0;
		int idIndex = 0;
		for (NSString *identifier in sceneImagesAndIdentifiers.identifiers)
		{
			NSLog(@"moving in Scene %d",sceneIndex);
			if ([identifier isEqualToString:target])
			{
				UIImageView *originalImageView = [sceneImagesAndIdentifiers.imageViews objectAtIndex:idIndex];
				originalImageView.hidden = NO;
				[originalImageView startAnimating];
				
				CGPoint originalCenter = originalImageView.center;
				CGPoint originalTopLeft = CGPointMake(0,0);
				originalTopLeft.x = originalCenter.x - (originalImageView.frame.size.width/2.0);
				originalTopLeft.y = originalCenter.y - (originalImageView.frame.size.height/2.0);
				
				CGPoint moveToPointTopLeft = CGPointMake(toX, toY);
				
				CGPoint moveToPointCenter = CGPointMake(0, 0);
				
				moveToPointCenter.x = moveToPointTopLeft.x + (originalImageView.frame.size.width/2.0);
				moveToPointCenter.y = moveToPointTopLeft.y + (originalImageView.frame.size.height/2.0);
				
				[UIView animateWithDuration:duration delay:delay options:kNilOptions animations:^{
					originalImageView.center = moveToPointCenter;
				}
								 completion:^(BOOL finished){
									 int x = 0;
									 x = originalImageView.frame.origin.x;
									 [originalImageView stopAnimating];
									 if (originalImageView.animationImages)
									 {
										 originalImageView.image = [originalImageView.animationImages lastObject];
									 }
									 
									 if (x >= (1024 * (sceneIndex + 1)) ||  x <= (1024 * sceneIndex))
									 {
										 originalImageView.hidden = YES;
									 }
									 else
									 {
										 originalImageView.hidden = NO;
									 }
								 }];
				delay++;
			}
			idIndex++;
			
		}
	}
	
	else if([move isKindOfClass:[NSArray class]])
	{
		for (NSDictionary *singleMove in move)
		{
			NSString *target = [singleMove objectForKey:@"-target"];
			int toX = [[singleMove objectForKey:@"-toX"] intValue] + (1024 * sceneIndex);
			int toY = [[singleMove objectForKey:@"-toY"] intValue];
			int duration = [[singleMove objectForKey:@"-duration"] intValue];
			duration /= 1000;
			int idIndex = 0;
			int delay = 0;
			for (NSString *identifier in sceneImagesAndIdentifiers.identifiers)
			{
				NSLog(@"moving in Scene %d",sceneIndex);
				if ([identifier isEqualToString:target])
				{
					UIImageView *originalImageView = [sceneImagesAndIdentifiers.imageViews objectAtIndex:idIndex];
					originalImageView.hidden = NO;
					[originalImageView startAnimating];
					
					CGPoint originalCenter = originalImageView.center;
					CGPoint originalTopLeft = CGPointMake(0,0);
					originalTopLeft.x = originalCenter.x - (originalImageView.frame.size.width/2.0);
					originalTopLeft.y = originalCenter.y - (originalImageView.frame.size.height/2.0);
					
					CGPoint moveToPointTopLeft = CGPointMake(toX, toY);
					
					CGPoint moveToPointCenter = CGPointMake(0, 0);
					
					moveToPointCenter.x = moveToPointTopLeft.x + (originalImageView.frame.size.width/2.0);
					moveToPointCenter.y = moveToPointTopLeft.y + (originalImageView.frame.size.height/2.0);
					
					[UIView animateWithDuration:duration delay:delay options:kNilOptions animations:^{
						originalImageView.center = moveToPointCenter;
					}
									 completion:^(BOOL finished) {
										 int x = 0;
										 x = originalImageView.frame.origin.x;
										 [originalImageView stopAnimating];
										 if (originalImageView.animationImages)
										 {
											 originalImageView.image = [originalImageView.animationImages lastObject];
										 }
										 
										 if (x >= (1024 * (sceneIndex + 1)) ||  x <= (1024 * sceneIndex))
										 {
											 originalImageView.hidden = YES;
										 }
										 else
										 {
											 originalImageView.hidden = NO;
										 }
									 }];
				}
				delay++;
				idIndex++;
			}
		}
	}//End of move animations
	
	
	//Actions animations	
	id tempHide = [actions objectForKey:@"Hide"];
	NSMutableArray *hideImagesArray = [NSMutableArray array];
	
	if ([tempHide isKindOfClass:[NSDictionary class]])
	{
		NSLog(@"Dictionary");
	}
	else if ([tempHide isKindOfClass:[NSArray class]])
	{
		for (NSDictionary *hideDictionary in tempHide)
		{
			int index = 0;
			NSString *target = [hideDictionary objectForKey:@"-target"];
			
			for (NSString *identifier in sceneImagesAndIdentifiers.identifiers)
			{
				if ([target isEqualToString:identifier])
				{
					UIImageView *imageView = [sceneImagesAndIdentifiers.imageViews objectAtIndex:index];
					if (imageView.image)
					{
						[hideImagesArray addObject:imageView.image];
					}
				}
				index++;
			}
		}
	}
	
	NSDictionary *hideDictionary = [tempHide objectAtIndex:0];
	NSString *target = [hideDictionary objectForKey:@"-target"];
	int repeatCount = [[scene objectForKey:@"-repeatCountForAction"] intValue];
	
	int index = 0;
	for (NSString *identifier in sceneImagesAndIdentifiers.identifiers)
	{
		if ([target isEqualToString:identifier])
		{
			UIImageView *imageView = [sceneImagesAndIdentifiers.imageViews objectAtIndex:index];
			imageView.animationImages = hideImagesArray;
			imageView.animationDuration = 1.0;
			if (repeatCount)
			{
				imageView.animationRepeatCount = repeatCount;
				imageView.image = [hideImagesArray lastObject];
			}
			[imageView startAnimating];
		}
		index++;
	}//End of action
}

- (void)stopAnimationsForSceneWithIndex:(NSInteger)sceneIndex
{
	NSDictionary *scene = [self.model.scenes objectAtIndex:sceneIndex];
	NSDictionary *actions = [scene objectForKey:@"Actions"];
	
	ImageAndID *sceneImagesAndIdentifiers = [self.allScenesImagesAndIDs objectAtIndex:sceneIndex];
	
	
	//move the imageview back to original position
	NSDictionary *objects = [scene objectForKey:@"Objects"];
	id cycle = [objects objectForKey:@"Cycle"];
	
	if ([cycle isKindOfClass:[NSDictionary class]])
	{
		NSString *target = [cycle objectForKey:@"-id"];
		int x = 0, y = 0, index = 0;
		x = [[cycle objectForKey:@"-x"] intValue] + (1024 * sceneIndex);
		y = [[cycle objectForKey:@"-y"] intValue];
		for (NSString *identifier in sceneImagesAndIdentifiers.identifiers)
		{
			if ([identifier isEqualToString:target])
			{
				UIImageView *imageView = [sceneImagesAndIdentifiers.imageViews objectAtIndex:index];
				int width = imageView.frame.size.width;
				int height = imageView.frame.size.height;
				imageView.frame = CGRectMake(x, y, width, height);
				[imageView startAnimating];
			}
			index++;
		}
	}
	else if ([cycle isKindOfClass:[NSArray class]])
	{
		for (NSDictionary *singleCycle in cycle)
		{
			NSString *target = [singleCycle objectForKey:@"-id"];
			int x = 0, y = 0, index = 0;
			x = [[singleCycle objectForKey:@"-x"] intValue] + (1024 * sceneIndex);
			y = [[singleCycle objectForKey:@"-y"] intValue];
			for (NSString *identifier in sceneImagesAndIdentifiers.identifiers)
			{
				if ([identifier isEqualToString:target])
				{
					UIImageView *imageView = [sceneImagesAndIdentifiers.imageViews objectAtIndex:index];
					int width = imageView.frame.size.width;
					int height = imageView.frame.size.height;
					imageView.frame = CGRectMake(x, y, width, height);
					[imageView startAnimating];
				}
				index++;
			}
		}
	}
	
	//Hide the imageview
	id move = [actions objectForKey:@"Move"];
	if ([move isKindOfClass:[NSDictionary class]])
	{
		NSString *target = [move objectForKey:@"-target"];
		
		int idIndex = 0;
		for (NSString *identifier in sceneImagesAndIdentifiers.identifiers)
		{
			if ([identifier isEqualToString:target])
			{
				UIImageView *originalImageView = [sceneImagesAndIdentifiers.imageViews objectAtIndex:idIndex];
				originalImageView.hidden = YES;
			}
			idIndex++;
		}
	}
	else if([move isKindOfClass:[NSArray class]])
	{
		for (NSDictionary *singleMove in move)
		{
			NSString *target = [singleMove objectForKey:@"-target"];
			
			int idIndex = 0;
			for (NSString *identifier in sceneImagesAndIdentifiers.identifiers)
			{
				if ([identifier isEqualToString:target])
				{
					UIImageView *originalImageView = [sceneImagesAndIdentifiers.imageViews objectAtIndex:idIndex];
					originalImageView.hidden = YES;
				}
				idIndex++;
			}
		}
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if ((int)(scrollView.contentOffset.x) % 1024 == 0)
	{
		NSInteger previousSceneIndex = self.previousSceneScrollPoint.x / 1024.0;
		NSLog(@"Stopping animations for Scene %d",previousSceneIndex);
		[self stopAnimationsForSceneWithIndex:previousSceneIndex];
		
		NSInteger sceneIndex = scrollView.contentOffset.x / 1024;
		[self doAnimationsForSceneWithIndex:sceneIndex];
		
		self.previousSceneScrollPoint = scrollView.contentOffset;
	}
}

- (void)viewDidUnload
{
	[self setStoryScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
