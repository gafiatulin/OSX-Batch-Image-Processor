//
//  CIImage+EasyFilters.m
//  Image Fun
//
//  Created by Victor Gafiatulin on 14/11/13.
//  Copyright (c) 2013 Victor Gafiatulin. All rights reserved.
//

#import "CIImage+EasyFilters.h"

@implementation CIImage (EasyGeometry)

-(CIImage*) resizeToWidth:(double)width andHeigth:(double)heigth
{
    @autoreleasepool
    {
        CIFilter* transform = [CIFilter filterWithName:@"CIAffineTransform"];
        NSAffineTransform* affineTransform = [NSAffineTransform transform];
        [affineTransform scaleXBy:width/self.extent.size.width yBy:heigth/self.extent.size.height];
        [transform setValue:affineTransform forKey:@"inputTransform"];
        [transform setValue:self forKey:@"inputImage"];
        return [transform valueForKey:@"outputImage"];
    }
}

-(CIImage*) cropWithX1: (double) x1 Y1: (double) y1 X2: (double) x2 Y2: (double) y2
{
    @autoreleasepool
    {
        CIFilter* transform = [CIFilter filterWithName:@"CIAffineTransform"];
        NSAffineTransform* affineTransform = [NSAffineTransform transform];
        [affineTransform translateXBy:-x1 yBy:-y1];
        [transform setValue:affineTransform forKey:@"inputTransform"];
        CGRect rect = CGRectMake(x1, y1, x2-x1, y2-y1);
        [transform setValue:[self imageByCroppingToRect:rect] forKey:@"inputImage"];
        return [transform valueForKey:@"outputImage"];
    }
}
-(CIImage*) rotateToAngle: (NSInteger) angle
{
    @autoreleasepool
    {
        CIFilter* transform = [CIFilter filterWithName:@"CIAffineTransform"];
        NSAffineTransform* affineTransform = [NSAffineTransform transform];
        [affineTransform rotateByDegrees:angle];
        [transform setValue:affineTransform forKey:@"inputTransform"];
        [transform setValue:self forKey:@"inputImage"];
        return [transform valueForKey:@"outputImage"];
    }
}

-(CIImage*) flipHorizontaly: (BOOL) hor andVertically: (BOOL) ver
{
    @autoreleasepool
    {
        CIFilter* transform = [CIFilter filterWithName:@"CIAffineTransform"];
        NSAffineTransform* affineTransform = [NSAffineTransform transform];
        [affineTransform scaleXBy:hor?-1.0:1.0 yBy:ver?-1.0:1.0];
        [transform setValue:affineTransform forKey:@"inputTransform"];
        [transform setValue:self forKey:@"inputImage"];
        return [transform valueForKey:@"outputImage"];
    }
}
-(CIImage*) colorControlWithSaturation:(double)sat brightness:(double) bri andContrast:(double) contr
{
    @autoreleasepool
    {
        CIFilter* transform = [CIFilter filterWithName:@"CIColorControls"];
        [transform setValue:@(sat) forKey:@"inputSaturation"];
        [transform setValue:@(bri) forKey:@"inputBrightness"];
        [transform setValue:@(contr) forKey:@"inputContrast"];
        [transform setValue:self forKey:@"inputImage"];
        return [transform valueForKey:@"outputImage"];
    }
}
-(CIImage*) blackAndWhiteFilter
{
    @autoreleasepool
    {
        CIFilter* transform = [CIFilter filterWithName:@"CIColorControls"];
        [transform setValue:@(0.0) forKey:@"inputSaturation"];
        [transform setValue:@(0.0) forKey:@"inputBrightness"];
        [transform setValue:@(1.1) forKey:@"inputContrast"];
        [transform setValue:self forKey:@"inputImage"];
        CIImage *result = [transform valueForKey:@"outputImage"];
        transform = [CIFilter filterWithName:@"CIExposureAdjust"];
        [transform setValue:result forKey:@"inputImage"];
        [transform setValue:@(0.7) forKey:@"inputEV"];
        return [transform valueForKey:@"outputImage"];
    }
}

-(CIImage*) cepiaFilter
{
    @autoreleasepool
    {
        CIFilter* transform = [CIFilter filterWithName:@"CISepiaTone"];
        [transform setValue:@(1.0) forKey:@"inputIntensity"];
        [transform setValue:self forKey:@"inputImage"];
        return [transform valueForKey:@"outputImage"];
    }
}
-(CIImage*) colorInvertFilter
{
    @autoreleasepool
    {
        CIFilter* transform = [CIFilter filterWithName:@"CIColorInvert"];
        [transform setValue:self forKey:@"inputImage"];
        return [transform valueForKey:@"outputImage"];
    }
}
-(CIImage*) blurFilterWithRadius: (double) rad
{
    @autoreleasepool
    {
        CIFilter* transform = [CIFilter filterWithName:@"CIGaussianBlur"];
        [transform setValue:self forKey:@"inputImage"];
        [transform setValue:@(rad) forKey:@"inputRadius"];
        return [[transform valueForKey:@"outputImage"] imageByCroppingToRect:CGRectMake(0, 0, self.extent.size.width, self.extent.size.height)];
    }
}

@end
