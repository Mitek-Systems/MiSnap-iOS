//
//  MiSnapScienceResults.h
//  MiSnapScience
//
//  Created by Stas Tsuprenko on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapScience/MiSnapScienceIQAResult.h>
#import <MiSnapScience/MiSnapScienceClassificationResult.h>
#import <MiSnapScience/MiSnapScienceExtractionResult.h>

/**
 Defines the IQA, classification and extraction results from analyzing a sample buffer
 */
@interface MiSnapScienceResult : NSObject

/**
 Image Quality Analysis (IQA) result
 */
@property (nonatomic, readonly) MiSnapScienceIQAResult * _Nonnull iqa;
/**
 Classification result
 */
@property (nonatomic, readonly) MiSnapScienceClassificationResult * _Nonnull classification;
/**
 Extraction result
 */
@property (nonatomic, readonly) MiSnapScienceExtractionResult * _Nullable extraction;
/**
 Indicates whether a given frame is acceptable based on IQA, Classification and Extraction results
 */
@property (nonatomic, readonly, getter=isAcceptable) BOOL acceptable;
/**
 An exception that was caught by the SDK
 */
@property (nonatomic, readonly) NSException * _Nullable exception;
/**
 Description of `MiSnapScienceResult`
 */
- (NSString * _Nonnull)description;

@end




