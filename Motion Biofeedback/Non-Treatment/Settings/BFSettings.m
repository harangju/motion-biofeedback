//
//  BFSettings.m
//  Motion Biofeedback
//
//  Created by Harang Ju on 3/14/14.
//  Copyright (c) 2014 Harang Ju. All rights reserved.
//

#import "BFSettings.h"

static NSString * const VisualizationKey = @"Visualization";
static NSString * const DimensionKey = @"Dimension";

@implementation BFSettings

+ (BFSettingsVisualization)visualization
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults objectForKey:VisualizationKey] integerValue];
}

+ (BOOL)setVisualization:(BFSettingsVisualization)visualization
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(visualization)
                     forKey:VisualizationKey];
    return [userDefaults synchronize];
}

+ (BFSettingsDimension)dimension
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [[userDefaults objectForKey:DimensionKey] integerValue];
}

+ (BOOL)setDimension:(BFSettingsDimension)dimension
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(dimension)
                     forKey:DimensionKey];
    return [userDefaults synchronize];
}

@end
