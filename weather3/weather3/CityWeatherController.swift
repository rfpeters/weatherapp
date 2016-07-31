//
//  CityWeatherController.swift
//  weather3
//
//  Created by Ryan Peters on 7/30/16.
//  Copyright © 2016 Ryan Peters. All rights reserved.
//

import Foundation
import UIKit

class CityWeatherController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var lowTempLabel: UILabel!
    @IBOutlet var highTempLabel: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var windLabel: UILabel!
    @IBOutlet var tempType: UISegmentedControl!
    @IBOutlet var cityText: UITextField!
    @IBOutlet var stateText: UITextField!
    @IBOutlet var weatherButton: UIButton!
    
    var city: String!
    var state: String!
    var tempF: Int!
    var tempC: Int!
    var lowTempF: Int!
    var highTempF: Int!
    var lowTempC: Int!
    var highTempC: Int!
    var desc: String!
    var humidity: Int!
    var windSpeed: Double!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tempType.enabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl){
        self.displayTemp()
    }
    
    @IBAction func buttonPressed(sender: UIButton){
        self.city = self.cityText.text
        self.state = self.stateText.text
        if self.city.isEmpty{
            self.errorLabel.backgroundColor = UIColor.redColor()
            self.errorLabel.text = "A city needs to be provided"
        }
        else if self.state.isEmpty{
            self.errorLabel.backgroundColor = UIColor.redColor()
            self.errorLabel.text = "A state needs to be provided"
        }
        else{
            self.getWeather()
        }
    }
    
    @IBAction func backgroundTapped(sender: AnyObject){
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getWeather(){
        let request = NSMutableURLRequest(URL: NSURL(string: "http://api.openweathermap.org/data/2.5/weather?appid=39400d2f250ab0fe4ac3b192f9903d08")!)
        request.HTTPMethod = "POST"
        let postString = "q=\(city),\(state)&units=imperial"
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
                    
                    if let code = json["cod"] as? Int{
                        if code == 200 {
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
                        else {
                            self.errorLabel.backgroundColor = UIColor.redColor()
                            self.errorLabel.text = "Unable to find city"
                        }
                    }
                    
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