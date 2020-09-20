//
//  WeatherManager.swift
//  Clima
//
//  Created by Leon Wong on 10/9/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

//By convenction we create the protocal in the same file as the class that would use the protocol
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) // the delegate should implement the func
    
    func didFailWithError(error: Error)
}

struct  WeatherManager{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=4bbb5a3df6d6d116bbf91b9097824c92&units=metric" // change http to https for secured connection
    
    var delegate: WeatherManagerDelegate?  // delegate: protocol
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) { //import CoreLocation to use the parameter CLLocationDegrees
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
        
    }
    
    func performRequest(with urlString: String) { //"with" is a external func name
        if let url = URL(string: urlString) { //1. create a url
            
            //2. Create a session
            let session = URLSession(configuration: .default)
            
            //3. Give url a task
            
            let task = session.dataTask(with: url){(data: Data?, response: URLResponse?, error: Error?) -> Void in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!) //unwrap and self
                    return //exit the function when there is error
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        
                        // self is needed for method inside a closure.
                        // turn JSON data to swift object
                        // pass the decoded JSON data(Swift Obj) back to ViewController
//                        let weatherVC = WeatherViewController()
//                        weatherVC.didUpdateWeather(weather: weather)
                        // this will limit WeatherManager() to one VC, ==> delegate
                        
                        
                        self.delegate?.didUpdateWeather(self,weather: weather) // again self. is needed for method inside closure
                        
                        
                    }
                }
            } // the task will tigger the completionHandler
            
            //4. start the task
            task.resume() // Newly-initialized tasks begin in a suspended state, so you need to call this method to start the task.
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedWeatherData = try decoder.decode(WeatherData.self, from: weatherData) // use .self on WeatherData to reference a type object.
            let id = decodedWeatherData.weather[0].id
            let temp = decodedWeatherData.main.temp
            let name = decodedWeatherData.name
            
            let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp)
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil //option return
        }// wrap try keyword inside a do block and catch the error
    }
    
    
    
}
