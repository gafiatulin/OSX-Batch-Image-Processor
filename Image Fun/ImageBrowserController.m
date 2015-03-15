//
//  ImageBrowserController.m
//  Image Fun
//
//  Created by Victor Gafiatulin on 12/11/13.
//  Copyright (c) 2013 Victor Gafiatulin. All rights reserved.
//

#import "ImageBrowserController.h"
#import <QuartzCore/CoreImage.h>
#import <ImageIO/ImageIO.h>

static NSArray *openFiles()
{
    NSOpenPanel *panel;
    panel = [NSOpenPanel openPanel];
    [panel setFloatingPanel:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:YES];
	NSInteger i = [panel runModal];
	if (i == NSOKButton)
    {
		return [panel URLs];
    }
    return nil;
}

@implementation ImageBrowserController

@synthesize images;
@synthesize importedImages;
@synthesize imageBrowser;
@synthesize fileNamesSet;

- (void)awakeFromNib
{
    images = [[NSMutableArray alloc] init];
    importedImages = [[NSMutableArray alloc] init];
    fileNamesSet = [[NSMutableOrderedSet alloc] init];
    [imageBrowser setAllowsReordering:YES];
    [imageBrowser setAnimates:YES];
    [imageBrowser setDraggingDestinationDelegate:self];
    [imageBrowser setZoomValue:0.5];
    [imageBrowser setCellsStyleMask:IKCellsStyleOutlined | IKCellsStyleShadowed];
    [imageBrowser setConstrainsToOriginalSize:YES];
    [imageBrowser setCanControlQuickLookPanel:YES];
}

- (void)updateDatasource
{
    [images addObjectsFromArray:importedImages];
    [importedImages removeAllObjects];
    [imageBrowser reloadData];
}

- (void)addAnImageWithPath:(NSString *)path
{
    if([[NSImage imageFileTypes] containsObject:[path pathExtension]])
        if(![fileNamesSet containsObject:path])
        {
            myImageObject *p;
            p = [[myImageObject alloc] init];
            [p setPath:path];
            [importedImages addObject:p];
            [fileNamesSet addObject:path];
            [self updateDatasource];
        }
}

- (void)addImagesWithPath:(NSString *)path recursive:(BOOL)recursive
{
    BOOL dir;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir] & dir)
    {
        NSArray *content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        for(NSString *elem in content)
        {
            if(recursive)
                [self addImagesWithPath:[path stringByAppendingPathComponent:elem] recursive:YES];
            else
                [self addAnImageWithPath:[path stringByAppendingPathComponent:elem]];
        }
        content = Nil;
    }
    else
        [self addAnImageWithPath:path];
}

- (void)addImagesWithPaths:(NSArray *)urls
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(NSURL *url in urls)
            [self addImagesWithPath:[url path] recursive:YES];
        dispatch_async(dispatch_get_main_queue(), ^{[self updateDatasource];});
    });
}

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view{return [images count];}

- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(NSUInteger)index{return [images objectAtIndex:index];}

- (void)imageBrowser:(IKImageBrowserView *)view removeItemsAtIndexes:(NSIndexSet *)indexes
{
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [fileNamesSet removeObject: [images[idx] path]];
    }];
	[images removeObjectsAtIndexes:indexes];
}

- (BOOL)imageBrowser:(IKImageBrowserView *)view moveItemsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)destinationIndex
{
    NSUInteger index;
    NSMutableArray *temporaryArray = [[NSMutableArray alloc] init];
    for (index = [indexes lastIndex]; index != NSNotFound; index = [indexes indexLessThanIndex:index])
    {
        if (index < destinationIndex)
            destinationIndex --;
        id obj = [images objectAtIndex:index];
        [temporaryArray addObject:obj];
        [images removeObjectAtIndex:index];
    }
    for (index=0; index < [temporaryArray count]; index++)
    {
        [images insertObject:[temporaryArray objectAtIndex:index] atIndex:destinationIndex];
    }
    temporaryArray = Nil;
    return YES;
}
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{return NSDragOperationCopy;}
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender{return NSDragOperationCopy;}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSData *data = nil;
    NSError *errorDescription;
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    if ([[pasteboard types] containsObject:NSFilenamesPboardType])
        data = [pasteboard dataForType:NSFilenamesPboardType];
    if (data)
    {
        NSArray *filenames = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&errorDescription];
        for (NSString *filename in filenames)
            [self addImagesWithPath:filename recursive:YES];
        [self updateDatasource];
    }
    data = Nil;
    pasteboard = Nil;
    return YES;
}

- (IBAction)addImageClicked:(NSButton *)sender
{
    NSArray *path = openFiles();
    if(!path){
        NSLog(@"No path selected, return...");
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{[self addImagesWithPaths:path];});
}

- (IBAction)zoomSliderDidChange:(NSSlider *)sender
{
    [imageBrowser setZoomValue:[sender floatValue]];
    [imageBrowser setNeedsDisplay:YES];
}

- (IBAction)angleChanged:(NSSlider *)sender{[_AngleLabel setStringValue:[@[@"90", @"0", @"270", @"180"][[sender intValue]] stringByAppendingString:@"°"]];}

- (IBAction)saturationChanged:(NSSlider *)sender{[_suturationLabel setStringValue:[@"" stringByAppendingFormat:@"%.2f", [sender floatValue]]];}
- (IBAction)brightnessChanged:(NSSlider *)sender{[_brightnessLabel setStringValue:[@"" stringByAppendingFormat:@"%.2f", [sender floatValue]]];}
- (IBAction)contrastChanged:(NSSlider *)sender{[_contrastLabel setStringValue:[@"" stringByAppendingFormat:@"%.2f", [sender floatValue]]];}
- (IBAction)blurValChanged:(NSSlider *)sender{[_blurFilter setTitle:[@"" stringByAppendingFormat:@"%.2f", [sender floatValue]]];}

- (IBAction)runButton:(NSButton *)sender
{
       BOOL isChanged = ([[_widthField stringValue] isValidSize] & [[_heigthField stringValue] isValidSize])||
       ([[_cropMinX stringValue] isValidSize]&[[_cropMinY stringValue] isValidSize]&[[_cropMaxX stringValue] isValidSize]&[[_cropMaxY stringValue] isValidSize])||
       [_HorizontalCheck intValue]||
       [_verticalCheck intValue]||
       [_bwFilter intValue]||
       [_sepiaFilter intValue]||
       ![[_AngleLabel stringValue] isEqualToString:@"0°"]||
       ![[_suturationLabel stringValue] isEqualToString:@"1.00"]||
       ![[_brightnessLabel stringValue] isEqualToString:@"0.00"]||
       ![[_contrastLabel stringValue] isEqualToString:@"1.00"]||
       [_blurFilter intValue] & ![[_blurFilter title] isEqualToString:@"0.00"]||
       [_colorInvertFilter intValue];
       if ([images count])
       {
           [sender setEnabled:NO];
           for (myImageObject *imageRef in [images copy])
               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                   if(isChanged)
                   {
                       CIContext *context = [CIContext contextWithCGContext:
                                             [[NSGraphicsContext currentContext] graphicsPort]
                                                                    options: nil];
                       
                       CIImage* transformedImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:imageRef.path]];
                       //Color Controls
                       if ((![[_suturationLabel stringValue] isEqualToString:@"1.00"]||![[_brightnessLabel stringValue] isEqualToString:@"0.00"]||![[_contrastLabel stringValue] isEqualToString:@"1.00"]))
                           transformedImage = [transformedImage colorControlWithSaturation:[_suturationLabel doubleValue]
                                                                                brightness:[_brightnessLabel doubleValue]
                                                                               andContrast:[_contrastLabel doubleValue]];
                       //Black and White
                       if ([_bwFilter intValue])
                           transformedImage = [transformedImage blackAndWhiteFilter];
                       //Sepia
                       if ([_sepiaFilter intValue])
                           transformedImage = [transformedImage cepiaFilter];
                       //Color Invert
                       if ([_colorInvertFilter intValue])
                           transformedImage = [transformedImage colorInvertFilter];
                       //Blur
                       if ([_blurFilter intValue])
                           transformedImage = [transformedImage blurFilterWithRadius:[[_blurFilter title] floatValue]];
                       //Resize
                       if([[_heigthField stringValue] isValidSize]& [[_widthField stringValue] isValidSize])
                           transformedImage = [transformedImage resizeToWidth: [_widthField doubleValue] andHeigth:[_heigthField doubleValue]];
                       //Crop
                       if([[_cropMinX stringValue] isValidSize]&
                          [[_cropMinY stringValue] isValidSize]&
                          [[_cropMaxX stringValue] isValidSize]&
                          [[_cropMaxY stringValue] isValidSize])
                           transformedImage = [transformedImage cropWithX1:[_cropMinX doubleValue]
                                                                        Y1:[_cropMinY doubleValue]
                                                                        X2:[_cropMaxX doubleValue]
                                                                        Y2:[_cropMaxY doubleValue]];
                       //Rotate
                       if(![[_AngleLabel.stringValue substringToIndex:[_AngleLabel.stringValue length]-1] isEqualToString:@"0"]){}
                       transformedImage = [transformedImage rotateToAngle: [[_AngleLabel.stringValue substringToIndex:[_AngleLabel.stringValue length]-1] integerValue]];
                       //Flip
                       if([_HorizontalCheck intValue] || [_verticalCheck intValue])
                           transformedImage = [transformedImage flipHorizontaly:[_HorizontalCheck intValue]
                                                                  andVertically:[_verticalCheck intValue]];
                       //Write to file
                       CGRect extent = [transformedImage extent];
                       CGImageRef cgImage = [context createCGImage:transformedImage fromRect:extent];
                       NSURL *fileURL = [NSURL fileURLWithPath:imageRef.path];
                       NSDictionary *fileTypeTokUTType = @{
                                                           @"jpg": (__bridge_transfer NSString *)kUTTypeJPEG,
                                                           @"jpeg": (__bridge_transfer NSString *)kUTTypeJPEG,
                                                           @"jpe": (__bridge_transfer NSString *)kUTTypeJPEG,
                                                           @"jp2": (__bridge_transfer NSString *)kUTTypeJPEG2000,
                                                           @"tiff": (__bridge_transfer NSString *)kUTTypeTIFF,
                                                           @"tif": (__bridge_transfer NSString *)kUTTypeTIFF,
                                                           @"gif": (__bridge_transfer NSString *)kUTTypeGIF,
                                                           @"png": (__bridge_transfer NSString *)kUTTypePNG,
                                                           @"qtif": (__bridge_transfer NSString *)kUTTypeQuickTimeImage,
                                                           @"icns": (__bridge_transfer NSString *)kUTTypeAppleICNS,
                                                           @"bmp": (__bridge_transfer NSString *)kUTTypeBMP,
                                                           @"dib": (__bridge_transfer NSString *)kUTTypeBMP,
                                                           @"ico": (__bridge_transfer NSString *)kUTTypeICO
                                                           };
                       CGImageDestinationRef dr = CGImageDestinationCreateWithURL((__bridge  CFURLRef)fileURL, (__bridge  CFStringRef)fileTypeTokUTType[[fileURL pathExtension]] , 1, NULL);
                       CGImageDestinationAddImage(dr, cgImage, NULL);
                       CGImageDestinationFinalize(dr);
                       CFRelease(dr);
                       CFRelease(cgImage);
                       imageRef.version+=1;
                   }
                   dispatch_async(dispatch_get_main_queue(),^{[self updateDatasource];});
               });
           [sender setEnabled:YES];
           
       }
}
@end
