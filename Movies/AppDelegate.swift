//
//  AppDelegate.swift
//  Movies
//
//  Created by Sarika on 19/01/19.
//  Copyright © 2019 Sarika. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var coreData = CoreDataStack()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        checkData()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreData.saveContext()
    }
    
    private func checkData(){
        let context = coreData.persistentContainer.viewContext
        let request : NSFetchRequest<Movie> = Movie.fetchRequest()
        
        if let movieCount = try? context.count(for: request), movieCount > 0 {
            return
        }
        uploadSampleData()
    }
    
    private func uploadSampleData(){
        let context = coreData.persistentContainer.viewContext
        /**
         we are checking if movie.json exist or not.
         if it exist then we transform result of the URL into Data and after that into JSON array.
         */
        guard
            /**
             fetching data from our json file
             */
            let url = Bundle.main.url(forResource:"movie", withExtension: "json"),
            //convert result into Data
            let data = try? Data(contentsOf: url), //once we have data then serialize it into dictionary
            let jsonResult = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary, //once we have dictionary , we convert it onto Json array
            let jsonArray = jsonResult?.value(forKey: "movie") as? NSArray
        
        else {return}
        
        /**
         Now iterating through fetcheddata from our json file and saving that data into our datamodel's enity = Movie
         */
        for json in jsonArray {
        
            print(json)
            guard
                let movieData = json as? [String : AnyObject],
                let title = movieData["name"] as? String,
                let userRating = movieData["rating"],
                let format = movieData["format"] as? String
            else{return}
            
            let moovie = Movie(context: context)
            moovie.title = title
            moovie.userRating = userRating.int16Value
            moovie.format = format
            
            if let imageName = movieData["image"] as? String,
                //converting string of image name into original image
                let image = UIImage(named: imageName),
                let imageData = image.jpegData(compressionQuality: 1.0)
                {
                    moovie.image = NSData.init(data: imageData)
                }
        }
        coreData.saveContext()
    }
}
