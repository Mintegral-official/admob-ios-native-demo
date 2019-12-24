//
//  MintegralMediatedNativeAd.h
//  Admob_SampleApp
//
//  Created by Damon on 2019/11/24.
//  Copyright © 2019 Chark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <MTGSDK/MTGSDK.h>

@interface MintegralMediatedNativeAd : NSObject<GADMediatedUnifiedNativeAd>

- (null_unspecified instancetype)init NS_UNAVAILABLE;

- (nullable instancetype)initAdWithNativeManager:(nonnull MTGNativeAdManager *)nativeManager mtgCampaign:(nonnull MTGCampaign *)campaign  withUnitId:(nonnull NSString *)unitId videoSupport:(BOOL)videoSupport nativeAdViewAdOptions:(nullable GADNativeAdViewAdOptions *)nativeAdViewAdOptions shouldDownloadImage:(BOOL)shouldDownloadImage NS_DESIGNATED_INITIALIZER;


@end


