//
//  MiSnapScienceResults.h
//  MiSnapScience
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MiSnapScience/MiSnapScienceIQAResult.h>
#import <MiSnapScience/MiSnapScienceClassificationResult.h>
#import <MiSnapScience/MiSnapScienceExtractionResult.h>

/**
 MiSnapSDKScienceResults is a class that defines the IQA, classification and extraction results from analyzing a video frame
 */
@interface MiSnapScienceResult : NSObject

//TODO: add comment
@property (nonatomic, readonly) MiSnapScienceIQAResult * _Nonnull iqa;

//TODO: add comment
@property (nonatomic, readonly) MiSnapScienceClassificationResult * _Nonnull classification;

//TODO: add comment
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
 - returns: Debug string
 */
- (NSString * _Nonnull)debugString;

@end




