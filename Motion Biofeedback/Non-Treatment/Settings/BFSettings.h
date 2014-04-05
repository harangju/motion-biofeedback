//
//  BFSettings.h
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BFSettingsVisualization)
{
    BFSettingsVisualizationCircle = 0,
    BFSettingsVisualizationVector = 1,
    BFSettingsVisualizationSentry = 2,
};

typedef NS_ENUM(NSInteger, BFSettingsDimension)
{
    BFSettingsDimensionsX = 0,
    BFSettingsDimensionsY = 1,
    BFSettingsDimensionsXAndY = 2,
    BFSettingsDimensionSentry = 3,
};

typedef NS_ENUM(NSInteger, BFSettingsDetection)
{
    BFSettingsDetectionMarker = 0,
    BFSettingsDetectionFeature = 1,
    BFSettingsDetectionSentry = 2,
};

@interface BFSettings : NSObject

+ (BFSettingsVisualization)visualization;
+ (BOOL)setVisualization:(BFSettingsVisualization)visualization;
+ (BFSettingsDimension)dimension;
+ (BOOL)setDimension:(BFSettingsDimension)dimension;
+ (BFSettingsDetection)detection;
+ (BOOL)setDetection:(BFSettingsDetection)detection;
+ (NSNumber *)millimeterPerPixelRatio;
+ (BOOL)setMillimeterPerPixelRatio:(CGFloat)ratio;

@end
