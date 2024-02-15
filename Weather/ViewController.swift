//
//  ViewController.swift
//  Weather
//
//  Created by Soto Nicole on 29.11.23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    struct WeatherInfo{
        
    }
    
    var city = "London"
    var lat = "40"
    var lon = "50"
    let backgrounds = ["Night", "MorningEvening", "Day", "MorningEvening"]
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //date label
        let currentTime = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        formatter.dateFormat = "yyyy/MM/dd HH:mm"

        let formattedString = formatter.string(from: currentTime)
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: backgrounds[getImageFromTime()])
        imageView.frame = view.bounds
        view.addSubview(imageView)
        
        var timeLabel = UILabel()
        timeLabel.textAlignment = .center
        timeLabel.textColor = .systemRed
        timeLabel.text = formattedString
        timeLabel.font = UIFont(name: "Thonburi-Bold", size: 25)!
        
        self.view.addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -350).isActive = true
        
        var cityLabel = UILabel()
        cityLabel.textAlignment = .center
        cityLabel.textColor = .black
        cityLabel.text = city
        cityLabel.font = UIFont(name: "Thonburi-Bold", size: 50)!
        self.view.addSubview(cityLabel)
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    cityLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 140),
                    cityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    cityLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                ])
        var tempLabel = UILabel()
        tempLabel.textAlignment = .center
        
        let strokeTextAttributes = [
          NSAttributedString.Key.strokeColor : UIColor.black,
          NSAttributedString.Key.foregroundColor : UIColor.red,
          NSAttributedString.Key.strokeWidth : -4.0,
          NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)]
          as [NSAttributedString.Key : Any]

        tempLabel.attributedText = NSMutableAttributedString(string: "Temp", attributes: strokeTextAttributes)
        tempLabel.font = UIFont(name: "Thonburi-Bold", size: 50)!
        tempLabel.layer.shadowColor = UIColor.systemPink.cgColor
        tempLabel.layer.shadowOffset = .zero
        tempLabel.layer.shadowRadius = 5.0
        tempLabel.layer.shadowOpacity = 1.0
        tempLabel.layer.masksToBounds = false
        tempLabel.layer.shouldRasterize = true
        self.view.addSubview(tempLabel)
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tempLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150).isActive = true
        
        
        // Timers
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let currentTime = Date()
            timeLabel.text = formatter.string(from: currentTime)
        }
        
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { timer in
            imageView.image = UIImage(named: self.backgrounds[self.getImageFromTime()])
        }
        getCurrentLocation()
        fetchData(city: city)
    }
     
    func getImageFromTime() -> Int {
        let currentTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        let formattedString = formatter.string(from: currentTime)
        //6 12 18 00
        return Int(formattedString)!/6
    }

    func fetchData(city: String){
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(self.lat).34&lon=\(self.lon).99&appid=ec762f072182a89b968cc6f6f7b96439") as! URL)
        request.httpMethod = "GET"

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse!)
            }
        })

        dataTask.resume()
    }
}

extension ViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.first! as CLLocation
        print("locations: \(userLocation.coordinate.latitude) \(userLocation.coordinate.longitude)")
        self.lat = String(userLocation.coordinate.latitude)
        self.lon = String(userLocation.coordinate.longitude)
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { placemarks, error in
            if error != nil { return }
            guard let placemarks = placemarks, let placemark = placemarks.first else { return }

            if let city = placemark.locality{
                self.city = city
                self.view.reloadInputViews()
            }
            print("\(self.city)\n")
        }
    }
    
    func getCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            print("Services enabled")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
}
