//
//  ViewController.swift
//  WeatherConditions
//
//  Created by Solomon Rajkumar on 18-12-15.
//  Copyright © 2015 SoluAppHouse. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    // outlet to city text field
    @IBOutlet weak var cityName: UITextField!
    
    // outlet for the result label
    @IBOutlet weak var weatherCondition: UILabel!
    
    // function to find weather of the city, when the button is pressed
    @IBAction func findWeather(sender: AnyObject) {
        
        // close the keypad
        self.view.endEditing(true)
        
        // pull the city name and remove blank spaces from the field
        let city = cityName.text!.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // frame the URL to be invoked
        let url = NSURL(string: "http://www.weather-forecast.com/locations/" + city + "/forecasts/latest")
        
        // create the virtual browser to download data over the web
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) -> Void in
            
            // check if valid data is present (offline or online)
            if let urlContent = data {
                
                // convert raw data to nsstring
                let webContent = NSString(data: urlContent, encoding: NSUTF8StringEncoding)
                
                // run the download data in background
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    // convert nsstring to string
                    let realWeatherString = self.findWeatherForecast(String(webContent))
                    
                    // set result label
                    self.weatherCondition.text = realWeatherString
                    
                    //self.weatherCondition.sizeToFit()
                    
                })
                
            } else {
                
                // error message in case of offline
                self.weatherCondition.text = "You are offline. Please connect to the internet!!"
                
            }
            
        }
        
        // start the web task
        task.resume()
        
    }
    
    // to parse the web content returned from website
    func findWeatherForecast(webContent : String) -> String {
        
        // weather string to be returned
        var realWeatherString = ""
        
        // find the string from where parsing has to start
        if let value = webContent.rangeOfString("3 Day Weather Forecast Summary:")  {
            
            // get the remainder of the string
            let substring = webContent.substringFromIndex(value.endIndex)
            
            // get the html content before weather data
            if let preWeatherString = substring.rangeOfString("phrase\">") {
                
                // weather content starts here
                let weatherString = substring.substringFromIndex(preWeatherString.endIndex)
                
                // find the ending of weather content
                if let realWeather = weatherString.rangeOfString(".</span") {
                    realWeatherString = weatherString.substringToIndex(realWeather.startIndex)
                }
                
            }
            
        }
        
        // invalid city
        else if let value = webContent.rangeOfString("404") {
            
            realWeatherString = "City name is invalid/not supported. Can you please try with a valid city"
            
        }


        /*
        
        // split the webcontent source code based on "find" string
        let websiteArray = webContent.componentsSeparatedByString("3 Day Weather Forecast Summary:</b><span class=\"read-more-small\"><span class=\"read-more-content\"> <span class=\"phrase\">")
        
        // if present
        if websiteArray.count > 1 {
            
            // find the string post weather conditions
            let weatherDataArray = websiteArray[1].componentsSeparatedByString("</span></span></span>")
            
            // find the weather data
            realWeatherString = weatherDataArray[0]
            
        } else {
            
            // invalid city based on 404 response
            realWeatherString = "City name is invalid/not supported. Can you please try with a valid city"
            
        }
        
        */
        
        // return proper weather data and use degree sign
        return realWeatherString.stringByReplacingOccurrencesOfString("&deg;", withString: "º")

        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }


}

