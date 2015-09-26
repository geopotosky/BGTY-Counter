//
//  BGClient.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/26/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//


import Foundation
import UIKit
import CoreData


class BGClient : NSObject {
    
    //* - Shared session
    var session: NSURLSession
    
    //* - Get the app delegate
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //* - Objects
    var events: Events!
    
//    var searchPhrase: String!
    
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    
    //* - Get Flickr Pictures Loop
    
    func getFlickrData(hostViewController: UIViewController, completionHandler: (success: Bool, pictureURL: String?, errorString: String?) -> Void) {
        
        //* - Assign Search Phrase shared value
        let searchPhrase = appDelegate.phraseText
        
        let methodArguments = [
            MethodArguments.method: Constants.METHOD_NAME,
            MethodArguments.api_key: Constants.API_KEY,
            //MethodArguments.bbox: self.createBoundingBoxString(),
            MethodArguments.text: searchPhrase,
            MethodArguments.safe_search: Constants.SAFE_SEARCH,
            MethodArguments.extras: Constants.EXTRAS,
            MethodArguments.format: Constants.DATA_FORMAT,
            MethodArguments.nojsoncallback: Constants.NO_JSON_CALLBACK
        ]
        
        self.getImageFromFlickrBySearch(methodArguments) { (success, pageNumber, errorString) in
            //* - Chain completion handlers for each request, if applicable, so that they run one after the other */
            //self.postSession(username, password: password) { (success, accountKey, errorString) in
            
            if success {
                self.getImageFromFlickrBySearchWithPage(methodArguments, pageNumber: pageNumber) { (success, pictureURL,errorString) in
                    //self.getUserData() { (success, errorString) in
                    if success {
                        completionHandler(success: true, pictureURL: pictureURL, errorString: errorString)
                    } else {
                        completionHandler(success: success, pictureURL: nil, errorString: errorString)
                    }
                }
            } else {
                completionHandler(success: success, pictureURL: nil, errorString: errorString)
            }
        }
    }
    
    
    
    //* ---------------------------- Flickr API ------------------------- */
    
    
//    /* Lat and Lon Function */
//    func createBoundingBoxString() -> String {
//        
//        /* Define the latitude and longitude constants */
//        //let latitude = (self.latitudeTextField.text as NSString).doubleValue
//        //let longitude = (self.longitudeTextField.text as NSString).doubleValue
//        let latitude = appDelegate.selectedLatitude
//        let longitude = appDelegate.selectedLongitude
//        
//        /* Fix added to ensure box is bounded by minimum and maximums */
//        let bottom_left_lon = max(longitude - Constants.BOUNDING_BOX_HALF_WIDTH, Constants.LON_MIN)
//        let bottom_left_lat = max(latitude - Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MIN)
//        let top_right_lon = min(longitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LON_MAX)
//        let top_right_lat = min(latitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MAX)
//        
//        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
//    }
    
    /* Function makes first request to get a random page, then it makes a request to get an image with the random page */
    func getImageFromFlickrBySearch(methodArguments: [String : AnyObject], completionHandler: (success: Bool, pageNumber: Int, errorString: String?) -> Void) {
        
        println("getImageFromFlickrBySearch")
        
        /* Get the Shared NSURLSession to facilitate Network Activity */
        let session = NSURLSession.sharedSession()
        /* Create the NSURLRequest using properly escaped URL  */
        let urlString = Constants.BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        println(urlString)
        println(url)
        println(request)
        
        
        /* Create NSURLSessionDataTask and completion handler */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(success: false, pageNumber: 0, errorString: "Could not complete the request \(error)")
            } else {
                
                println("download good")
                
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                //println(parsedResult)
                
                /* Get the photos dictionary */
                if let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject] {
                    
                    /* Determine the total number of photos */
                    if let totalPages = photosDictionary["pages"] as? Int {
                        
                        /* Flickr API - will only return up the 4000 images (100 per page * 40 page max) */
                        let pageLimit = min(totalPages, 40)
                        let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                        //self.getImageFromFlickrBySearchWithPage(methodArguments, pageNumber: randomPage)
                        completionHandler(success: true, pageNumber: randomPage, errorString: nil)
                        
                    } else {
                        completionHandler(success: false, pageNumber: 0, errorString: "Cant find key 'pages' in \(photosDictionary)")
                    }
                } else {
                    completionHandler(success: false, pageNumber: 0, errorString: "Cant find key 'photos' in \(parsedResult)")
                }
            }
        }
        /* Resume (execute) the task */
        task.resume()
    }
    
    func getImageFromFlickrBySearchWithPage(methodArguments: [String : AnyObject], pageNumber: Int, completionHandler: (success: Bool, pictureURL: String?, errorString: String?) -> Void) {
        
        println("getImageFromFlickrBySearchWithPage")
        
        /* Add the page to the method's arguments */
        var withPageDictionary = methodArguments
        withPageDictionary["page"] = pageNumber
        
        /* Get the Shared NSURLSession to facilitate Network Activity */
        let session = NSURLSession.sharedSession()
        /* Create the NSURLRequest using properly escaped URL  */
        let urlString = Constants.BASE_URL + escapedParameters(withPageDictionary)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        
        /* Create NSURLSessionDataTask and completion handler */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                completionHandler(success: false, pictureURL: nil, errorString: "Could not complete the request \(error)")
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                //println("2nd Parsed Result -------")
                //println(parsedResult)
                
                /* Get the photos dictionary */
                if let photosDictionary = parsedResult.valueForKey("photos") as? [String:AnyObject] {
                    
                    /* Determine the total number of photos */
                    var totalPhotosVal = 0
                    if let totalPhotos = photosDictionary["total"] as? String {
                        totalPhotosVal = (totalPhotos as NSString).integerValue
                    }
                    
                    /* If photos are returned, let's grab one! */
                    if totalPhotosVal > 0 {
                        if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                                
                                //var count1 = 0
                                //for photo in photosArray {
                                    //* - Grab 21 random images
                                    //if count1 <= 20 {
                                        // Grabs 1 image
                                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                                        let photoDictionary = photosArray[randomPhotoIndex] as [String:AnyObject]
                                        
                                        //* - Get the image url
                                        let imageUrlString = photoDictionary["url_m"] as? String
                                        let imageURL = NSURL(string: imageUrlString!)
                                        
                                        /* If an image exists at the url, set the image and title */
                                        if let imageData = NSData(contentsOfURL: imageURL!) {
                                            //dispatch_async(dispatch_get_main_queue(), {
                                            //dispatch_async(dispatch_get_main_queue()){
                                                println("found another")
                                                completionHandler(success: true, pictureURL: imageUrlString, errorString: nil)
                                            //} //End Dispatch
                                            //count1 += 1
                                            
                                        } else {
                                            completionHandler(success: false, pictureURL: nil, errorString: "Image does not exist at \(imageURL)")
                                        }
                                    //} //End count
                                    
                                    //completionHandler(success: true, pictureURL: imageUrlString, errorString: nil)
                                    
                                //}
                                //completionHandler(success: true, errorString: nil)
                            //}) //End Big Dispatch
                        } else {
                            completionHandler(success: false, pictureURL: nil, errorString: "Cant find key 'photo' in \(photosDictionary)")
                        }
                    } else {
                        //                        dispatch_async(dispatch_get_main_queue(), {
                        //                            self.pinImage.image = nil
                        //                        })
                    }
                } else {
                    completionHandler(success: false, pictureURL: nil, errorString: "Cant find key 'photos' in \(parsedResult)")
                }
            }
        }
        
        task.resume()
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    //* ------------------------ End Flickr API -------------------------- */
    
    
    
    //* - Shared Instance
    
    class func sharedInstance() -> BGClient {
        
        struct Singleton {
            static var sharedInstance = BGClient()
        }
        
        return Singleton.sharedInstance
    }
    
    
    //* - Shared Image Cache
    
//    struct Caches {
//        static let imageCache = ImageCache()
//    }
    
    
}
