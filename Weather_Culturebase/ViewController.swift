//
//  ViewController.swift
//  Weather_Culturebase
//
//  Created by Alexander Claussen on 7/12/19.
//  Copyright © 2019 Alexander Claussen. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    let locationManager = CLLocationManager()
    
    let defaultSession = URLSession(configuration: .default)
    //default coordinates are for antartica. will check to see if these values have changed
    var latitude: Double = -90
    var longitude: Double = 90
    var locationKey: String = "2628204"
    var dataTask: URLSessionDataTask?
    var degrees: Int = 0
    var slide1:Day = Bundle.main.loadNibNamed("Day", owner: self, options: nil)?.first as! Day
     var slide2:Day = Bundle.main.loadNibNamed("Day", owner: self, options: nil)?.first as! Day
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
    }
    
    func createSlides() -> [Day] {
        
        
        slide1.mainLabel.text = "Today's Weather"
        slide1.degrees.text = "Loading..."
        
        
 
         slide1.mainLabel.text = "Tomorrow's Weather"
        slide2.degrees.text = "Loading..."
        
        
        return [slide2, slide1]
    }
    
    var slides:[Day] = [];
    
    override func viewDidLoad() {
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //print("here in enabled")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            //startLoad()
        } else {
            print("location services not enabled.")
        }

        
        
        self.scrollView.delegate = self
        self.scrollView.showsHorizontalScrollIndicator = false 
        
        super.viewDidLoad()
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
        

        
        
        
        
    }
    
    
    /*
 
     They way the particular weather API is setup, 3 seperate calls will be necessary
     
     startLoad(), startLoad2(), and startLoad3() methods described below execute these 3 api calls
     
     the API key is registered to my email address
     
     startLoad() sends the api service the latitude and longitude coordinates, returning a key that the api requires to get weather data. For example the key "2628204" corresponds to Sanfrancisco. "2628204" would be a value sent in subsequent API calls to get the weather if you wanted informatino on the weather in sanfrancisco
     
     startload1() takes the key and gets current weather
     
     startLoad2() takes the key and gets the forecast for tomorrow
 
 
 
 
 
 */
/*
    func startLoad() {
        let session = URLSession.shared
        //let urlString1: String = "https://dataservice.accuweather.com/currentconditions/v1/2628204?apikey=rP1VDRml9KwLVg4qLpEQC4wmRoLTGoUl"
        let urlString1: String = "https://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=rP1VDRml9KwLVg4qLpEQC4wmRoLTGoUl&q=" + String(latitude) + "%2C" + String(longitude)
        print(urlString1)
        let url1 = URL(string: urlString1)!
        
        
        let task1 = session.dataTask(with: url1) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                
            
                
                print(json ?? "did not work")
                
                
                if let key = json?["Key"] as? String {
                    print("keyValue:")
                    print(key)
                    self.locationKey = key
                
                }


            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        
        task1.resume()
        
       
        
    }
    /*
    func startLoad2() {
        let session = URLSession.shared
        var UrlString2: String = "https://dataservice.accuweather.com/currentconditions/v1/" + locationKey + "?apikey=rP1VDRml9KwLVg4qLpEQC4wmRoLTGoUl"
        
        print(UrlString2)
        let url2 = URL(string: UrlString2)!
        
        let task2 = session.dataTask(with: url2) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            
            do {
                var string1 = String(data: data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                print(string1)
                string1.remove(at: string1.startIndex)
                string1.remove(at: string1.index(before: string1.endIndex))
                print(string1)
                var data2: Data? = string1.data(using: .utf8)
                let json = try JSONSerialization.jsonObject(with: data2!, options: []) as? [String: Any]
                
                
                print("second round of api call")
                print(json ?? "did not work")
                
                
                if let temp = json?["Temperature"] as? [String:Any] {
                    print("temperature:")
                    print(temp)
                         if let tempImperial = temp["Imperial"] as? [String:Any] {
                            print("temperature Imperial:")
                            print(tempImperial)
                            
                            if let tempF  = tempImperial["Value"] as? Int {
                                print("temperature in degrees F:")
                                print(tempF)
                                //updating with today's forecast
                                //ommiting the DispatchQueue will result in errors described in the following stack overflow question
                          //https://stackoverflow.com/questions/28302019/getting-a-this-application-is-modifying-the-autolayout-engine-from-a-background
                                DispatchQueue.main.async {
                                self.slide2.degrees.text = String(tempF) + " degrees F"
                                }
                            }
                            
                    }
                    
                }
                
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        
        task2.resume()
    }
 
 */
    
    /*
    func startLoad3() {
        let session = URLSession.shared
        var UrlString3: String = "https://dataservice.accuweather.com/currentconditions/v1/" + locationKey + "?apikey=rP1VDRml9KwLVg4qLpEQC4wmRoLTGoUl"
        
        print(UrlString2)
        let url2 = URL(string: UrlString2)!
        
        let task2 = session.dataTask(with: url2) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            
            do {
                var string1 = String(data: data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                print(string1)
                string1.remove(at: string1.startIndex)
                string1.remove(at: string1.index(before: string1.endIndex))
                print(string1)
                var data2: Data? = string1.data(using: .utf8)
                let json = try JSONSerialization.jsonObject(with: data2!, options: []) as? [String: Any]
                
                
                print("second round of api call")
                print(json ?? "did not work")
                
                
                if let temp = json?["Temperature"] as? [String:Any] {
                    print("temperature:")
                    print(temp)
                    if let tempImperial = temp["Imperial"] as? [String:Any] {
                        print("temperature Imperial:")
                        print(tempImperial)
                        
                        if let tempF  = tempImperial["Value"] as? Int {
                            print("temperature in degrees F:")
                            print(tempF)
                            //updating with today's forecast
                            //ommiting the DispatchQueue will result in errors described in the following stack overflow question
                            //https://stackoverflow.com/questions/28302019/getting-a-this-application-is-modifying-the-autolayout-engine-from-a-background
                            DispatchQueue.main.async {
                                self.slide2.degrees.text = String(tempF) + " degrees F"
                            }
                        }
                        
                    }
                    
                }
                
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        
        task2.resume()
    }
 */
 */
    
    func startLoad4() {
        let session = URLSession.shared
        var UrlString: String = "https://api.weather.gov/points/" + String(latitude) + "," + String(longitude)
        
        print(UrlString)
        let url = URL(string: UrlString)!
        
        let task = session.dataTask(with: url) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error!")
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type!")
                return
            }
            
            do {
                var string1 = String(data: data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                print(string1)
                string1.remove(at: string1.startIndex)
                string1.remove(at: string1.index(before: string1.endIndex))
                print(string1)
                var data2: Data? = string1.data(using: .utf8)
                let json = try JSONSerialization.jsonObject(with: data2!, options: []) as? [String: Any]
                
                
                print("second round of api call")
                print(json ?? "did not work")
                
                
                if let temp = json?["Temperature"] as? [String:Any] {
                    print("temperature:")
                    print(temp)
                    if let tempImperial = temp["Imperial"] as? [String:Any] {
                        print("temperature Imperial:")
                        print(tempImperial)
                        
                        if let tempF  = tempImperial["Value"] as? Int {
                            print("temperature in degrees F:")
                            print(tempF)
                            //updating with today's forecast
                            //ommiting the DispatchQueue will result in errors described in the following stack overflow question
                            //https://stackoverflow.com/questions/28302019/getting-a-this-application-is-modifying-the-autolayout-engine-from-a-background
                            DispatchQueue.main.async {
                                self.slide2.degrees.text = String(tempF) + " degrees F"
                            }
                        }
                        
                    }
                    
                }
                
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    func setupSlideScrollView(slides : [Day]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("hi")
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
   
       
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        if (latitude !=  locValue.latitude || longitude != locValue.longitude)
        {
    
       startLoad4()
        
        } else {
            print("here")
        }
    }

   

}

