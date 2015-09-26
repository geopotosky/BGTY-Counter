//
//  BGConstants.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/26/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

//
//  VTConstants.swift
//  VirtualTourist
//
//  Created by George Potosky on 9/9/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

extension BGClient {
    
    //* - Constants
    struct Constants {
        
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let METHOD_NAME = "flickr.photos.search"
        static let API_KEY = "1a9dd8f528bb7e17deb54780ded8bc06"
        static let EXTRAS = "url_m"
        static let SAFE_SEARCH = "1"
        static let DATA_FORMAT = "json"
        static let NO_JSON_CALLBACK = "1"
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
        
    }
    
    //* - Parameter Keys
    struct MethodArguments {
        
        static let method = "method"
        static let api_key = "api_key"
        static let text = "text"
        static let safe_search = "safe_search"
        static let extras = "extras"
        static let format = "format"
        static let nojsoncallback = "nojsoncallback"
    }
    
}

