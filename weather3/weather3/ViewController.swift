//
//  ViewController.swift
//  weather3
//
//  Created by Ryan Peters on 7/28/16.
//  Copyright © 2016 Ryan Peters. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var lowTempLabel: UILabel!
    @IBOutlet var highTempLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var windLabel: UILabel!
    @IBOutlet var tempType: UISegmentedControl!
    
    var coordLat: Double!
    var coordLon: Double!
    var tempF: Int!
    var tempC: Int!
    var lowTempF: Int!
    var highTempF: Int!
    var lowTempC: Int!
    var highTempC: Int!
    var name: String!
    var desc: String!
    var humidity: Int!
    var windSpeed: Double!
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getLocation()
    }
    
    func applicationWillEnterForeground(notification: NSNotification) {
        self.getLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl){
        self.displayTemp()
    }
    
    func getLocation(){
        self.tempType.enabled = false
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations location: [CLLocation]) {
        let loc = location.last!
        let locValue = loc.coordinate
        self.coordLat = locValue.latitude
        self.coordLon = locValue.longitude
        getWeather()
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func getWeather(){
        let request = NSMutableURLRequest(URL: NSURL(string: "http://api.openweathermap.org/data/2.5/weather?appid=39400d2f250ab0fe4ac3b192f9903d08")!)
        request.HTTPMethod = "POST"
        let postString = "lat=\(coordLat)&lon=\(coordLon)&units=imperial"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                self.errorLabel.backgroundColor = UIColor.redColor()
                self.errorLabel.text = "Unable to get data from server"
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                self.errorLabel.backgroundColor = UIColor.redColor()
                self.errorLabel.text = "Unable to get data from server"
            }
            
            do {
                
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                dispatch_async(dispatch_get_main_queue()) {
                    
                    print(json) //test
                    //get location name
                    self.name = json["name"] as! String
                    self.locationLabel.text = self.name
                    
                    //get weather description
                    let weather = json["weather"] as? [[String: AnyObject]]
                    self.desc = weather![0]["description"] as! String
                    self.descLabel.text = self.desc
                    
                    //get temp
                    let main = json["main"] as? [String: AnyObject]
                    self.tempF = main!["temp"] as! Int
                    self.tempC = self.convertFToC(self.tempF)
                    self.lowTempF = main!["temp_min"] as! Int
                    self.lowTempC = self.convertFToC(self.lowTempF)
                    self.highTempF = main!["temp_max"] as! Int
                    self.highTempC = self.convertFToC(self.highTempF)
                    self.displayTemp()
                    
                    //get humidity
                    self.humidity = main!["humidity"] as! Int
                    self.humidityLabel.text = String(self.humidity)
                    
                    //get wind speed
                    let wind = json["wind"] as? [String: AnyObject]
                    self.windSpeed = wind!["speed"] as! Double
                    self.windLabel.text = String(self.windSpeed)
                    self.tempType.enabled = true
                }
                
            }
            catch _ {
                self.errorLabel.backgroundColor = UIColor.redColor()
                self.errorLabel.text = "Unable to read weather data"
            }
        }
        task.resume()
    }
    
    func convertFToC(temp: Int) -> Int{
        return Int(Double(temp - 32) * Double(5.0/9.0))
    }
    
    func displayTemp(){
        switch tempType.selectedSegmentIndex{
        case 0:
            if self.tempF >= 85 {
                self.tempLabel.textColor = UIColor.redColor()
            }
            else if self.tempF <= 50{
                self.tempLabel.textColor = UIColor.blueColor()
            }
            self.tempLabel.text = String(self.tempF)
            self.lowTempLabel.text = "Lo: \(self.lowTempF)"
            self.highTempLabel.text = "Hi: \(self.highTempF)"

        case 1:
            if self.tempC >= 30 {
                self.tempLabel.textColor = UIColor.redColor()
            }
            else if self.tempF <= 10{
                self.tempLabel.textColor = UIColor.blueColor()
            }
            self.tempLabel.text = String(self.tempC)
            self.lowTempLabel.text = "Lo: \(self.lowTempC)"
            self.highTempLabel.text = "Hi: \(self.highTempC)"

        default:
            break;
        }
    }
    
}

