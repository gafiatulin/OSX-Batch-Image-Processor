//
//  CIImage+EasyFilters.h
//  Image Fun
//
//  Created by Victor Gafiatulin on 14/11/13.
//  Copyright (c) 2013 Victor Gafiatulin. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface CIImage (EasyGeometry)
-(CIImage*) resizeToWidth:(double)width andHeigth:(double)heigth;
-(CIImage*) cropWithX1: (double) x1 Y1: (double) y1 X2: (double) x2 Y2: (double) y2;
-(CIImage*) rotateToAngle: (NSInteger) angle;
-(CIImage*) flipHorizontaly: (BOOL) hor andVertically: (BOOL) ver;
-(CIImage*) colorControlWithSaturation:(double)sat brightness:(double) bri andContrast:(double) contr;
-(CIImage*) blackAndWhiteFilter;
-(CIImage*) cepiaFilter;
-(CIImage*) colorInvertFilter;
-(CIImage*) blurFilterWithRadius: (double) rad;
@end
