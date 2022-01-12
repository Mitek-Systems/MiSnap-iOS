//
//  MiSnapBarcodeScannerMibiData.h
//  MiSnapBarcodeScanner
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiSnapBarcodeScanner/MiSnapBarcodeScanner.h>

@interface MiSnapBarcodeScannerMibiData : NSObject

+ (NSMutableDictionary *)getMibiDataWithResult:(NSString *)resultCode
                               andTorchStatus:(NSString *)torchState;

@end
