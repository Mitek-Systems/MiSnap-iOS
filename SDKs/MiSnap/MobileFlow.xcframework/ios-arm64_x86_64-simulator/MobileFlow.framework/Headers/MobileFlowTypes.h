//
//  MobileFlowTypes.h
//  MobileFlow
//
//  Created by Jeremy Jessup on 6/28/16.
//  Copyright © 2016 Mitek Systems. All rights reserved.
//

#ifndef MobileFlowTypes_h
#define MobileFlowTypes_h

/**
 *  The types of documents that the MobileFlow library can process
 */
typedef NS_ENUM(NSInteger, MobileFlowDocType)
{
    /**
     *  Check Front
     */
    MF_DOC_TYPE_CHECK_FRONT,

    /**
     *  Check back
     */
    MF_DOC_TYPE_CHECK_BACK,

    /**
     *  Drivers license
     */
    MF_DOC_TYPE_DRIVERS_LICENSE,

    /**
     *  Passport
     */
    MF_DOC_TYPE_PASSPORT,

    /**
     *  Generic (not a specific type)
     */
    MF_DOC_TYPE_GENERIC,
    
    /**
     * 1 line MRZ
     */
    MF_DOC_TYPE_1LINE_MRZ,
    
    /**
     * TD1 document type
     */
    MF_DOC_TYPE_TD1,
    
    /**
     * TD2 document type
     */
    MF_DOC_TYPE_TD2
};


/**
 *  Various processing options that can be set when analyzing a frame or image.
 *  These values can be logically OR'd together.
 */
typedef NS_OPTIONS(NSInteger, MobileFlowProcessOptions)
{
	/**
	 *  No processing
	 */
	MF_PROCESS_NONE					= 0,
	
	/**
	 *  Glare detection
	 */
	MF_PROCESS_GLARE				= 1 << 1,
	
	/**
	 *  Out of focus
	 */
	MF_PROCESS_OUT_OF_FOCUS			= 1 << 2,
	
	/**
	 *  Exposure
	 */
	MF_PROCESS_EXPOSURE				= 1 << 3,
	
	/**
	 *  Dewarp and deskew the image using four-corner results
	 */
	MF_PROCESS_GRAY_DEWARP			= 1 << 4,
	
	/**
	 *  Dewarp and deskew the color image using four-corner results
	 */
	MF_PROCESS_COLOR_DEWARP			= 1 << 5,
	
	/**
	 *  Process check MICR generically (USA/non-USA allowed)
	 */
	MF_PROCESS_GENERIC_CHECK		= 1 << 6,
	
	/**
	 *  Performs typical mobile analysis stages
	 */
	MF_PROCESS_MOBILE				= (MF_PROCESS_GLARE | MF_PROCESS_EXPOSURE | MF_PROCESS_OUT_OF_FOCUS),

	/**
	 *  Perform all processing steps
	 */
	MF_PROCESS_ALL					= (MF_PROCESS_MOBILE | MF_PROCESS_GRAY_DEWARP | MF_PROCESS_COLOR_DEWARP),
};


#endif /* MobileFlowTypes_h */
