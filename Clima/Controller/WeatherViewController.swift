//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self // Documentation: When using this method, the associated delegate must implement the locationManager(_:didUpdateLocations:) and locationManager(_:didFailWithError:) methods. Failure to do so is a programmer error.
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation() // one time location info
        
        locationManager.delegate = self
        weatherManager.delegate = self //rmb to adopt the protocol first
        searchTextField.delegate = self // noify the view controller on action related with TextField
        
    }
    
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    
    
    
    
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //handles what should happen after Go/Return is pressed
        searchTextField.endEditing(true)
        print(searchTextField.text! )
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //trap users in editing mode
        if textField.text != ""{
            return true
        } else {
            textField.placeholder = "Please enter a location name"
            return false
        }
        // why use textField but not the IBOutlet searchTextField?
        // Because just multiple button linked to same IBAction, multiple button can be the sender.
        // and if we set textFieldA = self and textFieldB = self, then we will have multiple "sender" (textField) that will tigger this method.
        // if we dont care which textField is used, we can simply use textField in our condition.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //handle what happen when editing ended
        
        //just before we empty the text, we want to use the text to get the weather for that city.
        
        if let city = searchTextField.text {
            
            weatherManager.fetchWeather(cityName: city)
        }
        
        searchTextField.text = "" // clears text field after hitting return
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel){
        // the WeatherModel is fetched from WeatherManager
        //temperatureLabel.text = weather.temperatureString //error: this is depend on the completion handler so it may need to wait
        DispatchQueue.main.async {//it is a closure, need to put self infront
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
        
    }
    
    
    func didFailWithError(error: Error) {
        print(error)
    }
}


//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    //When using this method, the associated delegate must implement the locationManager(_:didUpdateLocations:) and locationManager(_:didFailWithError:) methods. Failure to do so is a programmer error.
    
    //The didUpdate and didFail method is trigger by requestionLocation()
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLoc = locations.last { //unwrap it with optional binding
            
            locationManager.stopUpdatingLocation() // stop updating once we got location so didUpdate method can be trigger again i.e. when pressing loc buttion.
            
            weatherManager.fetchWeather(latitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude)
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
