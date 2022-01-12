//
//  MiSnapBarcodeScannerLightMibiData.h
//  MiSnapBarcodeScannerLight
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MiSnapBarcodeScannerLight.h"

@interface MiSnapBarcodeScannerLightMibiData : NSObject

+ (NSMutableDictionary *)getMibiDataWithResult:(NSString *)resultCode
                               andTorchStatus:(NSString *)torchState;

@end
