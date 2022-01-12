//
//  MiSnapBarcodeScanner+NSString.h
//  MiSnapBarcodeScannerUX
//
//  Created by Mitek Engineering on 10/14/2020.
//  Copyright © 2020 Mitek Systems Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MiSnapBarcodeScanner)

/**
 Returns the localized string from the FacialCaptureLocalizable string table.
 If the key is not found, it's returned as the default value.
 
 @param key The lookup key associated with a translated value
 @return The localized string value
 @see FacialCaptureLocalizable.strings
 */
+ (NSString *)localizedStringForKey:(NSString *)key;

@end
