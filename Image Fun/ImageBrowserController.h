//
//  ImageBrowserController.h
//  Image Fun
//
//  Created by Victor Gafiatulin on 12/11/13.
//  Copyright (c) 2013 Victor Gafiatulin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSString+ValidSize.h"
#import "CIImage+EasyFilters.h"
#import "myImageObject.h"

@interface ImageBrowserController : NSWindowController
@property (nonatomic, strong) NSMutableOrderedSet *fileNamesSet;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *importedImages;
@property (weak) IBOutlet IKImageBrowserView *imageBrowser;
@property (weak) IBOutlet NSTextField *widthField;
@property (weak) IBOutlet NSTextField *heigthField;
@property (weak) IBOutlet NSTextField *AngleLabel;
@property (weak) IBOutlet NSButton *HorizontalCheck;
@property (weak) IBOutlet NSButton *verticalCheck;
@property (weak) IBOutlet NSTextField *cropMinX;
@property (weak) IBOutlet NSTextField *cropMinY;
@property (weak) IBOutlet NSTextField *cropMaxX;
@property (weak) IBOutlet NSTextField *cropMaxY;
@property (weak) IBOutlet NSTextField *brightnessLabel;
@property (weak) IBOutlet NSTextField *contrastLabel;
@property (weak) IBOutlet NSTextField *suturationLabel;
@property (weak) IBOutlet NSButton *bwFilter;
@property (weak) IBOutlet NSButton *sepiaFilter;
@property (weak) IBOutlet NSButton *colorInvertFilter;
@property (weak) IBOutlet NSButton *blurFilter;
- (IBAction)zoomSliderDidChange:(NSSlider *)sender;
- (IBAction)angleChanged:(NSSlider *)sender;
- (IBAction)addImageClicked:(NSButton *)sender;
- (IBAction)saturationChanged:(NSSlider *)sender;
- (IBAction)brightnessChanged:(NSSlider *)sender;
- (IBAction)contrastChanged:(NSSlider *)sender;
- (IBAction)blurValChanged:(NSSlider *)sender;
- (IBAction)runButton:(NSButton *)sender;
@end
