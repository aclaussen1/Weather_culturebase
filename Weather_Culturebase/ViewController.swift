//
//  ViewController.swift
//  Weather_Culturebase
//
//  Created by Alexander Claussen on 7/12/19.
//  Copyright © 2019 Alexander Claussen. All rights reserved.
//

// Log of Activities
//
/*
 July 13 8:39pm: Current status: So I had initially used a particular API (https://dataservice.accuweather.com/currentconditions/v1/2628204?apikey=rP1VDRml9KwLVg4qLpEQC4wmRoLTGoUl)
    I had to create an API account to get the key for this particular api. Everything was working fine. It had to make 3 different api calls to get both todays weather and tomorrows. It was working great in the Simulator. Then I tried it on my real iOS device and the problem that happened was
        I had 3 methods, each to make an API call. And they were all being called from  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {.
        The thing is this method only gets called 1-3 times on the Simulator. However it appears on a real device that it gets called a lot, like multiple times a second. Therfore the code was making a shit ton of API calls and then the API service realized this and maxed out. So making that API call using that key and url no longer worked. THis was happening on Friday.
    Today is Saturday and I am trying the API again and now it seems to work. It seems like maybe there is a daily cap. Before Friday ended I also tried the national government weather service API, which does not require an API key, so I might have been able to get around the daily limits. So the question now is do I switch APIs or stick with the one that was working temporarily on Friday, but figure out how to limit the number of calls being made?
    If this were a real production application and was looking for a free service I'd definitely move over to the government one. But this is a basic assignment and I'm just trying to get barebones functionality so I'll just modify it so its restricted in making calls only once every 30 seconds or so.
 9:39p
 
 Well it appears that the existing api can't even do forecasts an hour out without paying for the service so I am stuck with using national weather api
 
 
 */

import UIKit
import CoreLocation

class ViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    let locationManager = CLLocationManager()
    
    let defaultSession = URLSession(configuration: .default)
    //default coordinates are for antartica. will check to see if these values have changed
    var latitude: Double = 33.7490
    var timestamp = NSDate().timeIntervalSince1970
    var numberOfTimesCalledAPI = 0
    var longitude: Double = -84.3880
    //san francisco key
    //var locationKey: String = "2628204"
    var locationKey: String = "2625833"
    var dataTask: URLSessionDataTask?
    var degrees: Int = 0
    public  var URLForNationalWeatherServiceForecast: String = "" {
        willSet(newURLForNationalWeatherServiceForecast) {
            print("About to set URLForNationalWeatherServiceForecast to \(newURLForNationalWeatherServiceForecast)")
        }
        didSet {
            startLoad6()
        }
    }
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
        
        print("timestamp:")
        print(timestamp)
        
        
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
        
        startLoad()
        startLoad2()
        
        startLoad4()
        startLoad5()
        startLoad6()
        
        
        
        
    }
    
    
    /*
 
     They way the particular weather API is setup, 3 seperate calls will be necessary
     
     startLoad(), startLoad2(), and startLoad3() methods described below execute these 3 api calls
     
     the API key is registered to my email address
     
     startLoad() sends the api service the latitude and longitude coordinates, returning a key that the api requires to get weather data. For example the key "2628204" corresponds to Sanfrancisco. "2628204" would be a value sent in subsequent API calls to get the weather if you wanted informatino on the weather in sanfrancisco
     
     startload1() takes the key and gets current weather
     
     startLoad2() takes the key and gets the forecast for tomorrow
 
 
 
 
 
 */

    func startLoad() {
        let session = URLSession.shared
        //let urlString1: String = "https://dataservice.accuweather.com/currentconditions/v1/2628204?apikey=rP1VDRml9KwLVg4qLpEQC4wmRoLTGoUl"
        let urlString1: String = "https://dataservice.accuweather.com/locations/v1/cities/geoposition/search?apikey=rP1VDRml9KwLVg4qLpEQC4wmRoLTGoUl&q=" + String(latitude) + "%2C" + String(longitude)
        print(urlString1)
        let url1 = URL(string: urlString1)!
        
        
        let task1 = session.dataTask(with: url1) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error in load 1!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error in startLOad!")
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type in StartLoad()!")
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
 
 
    func startLoad2() {
        let session = URLSession.shared
        let UrlString2: String = "https://dataservice.accuweather.com/currentconditions/v1/" + locationKey + "?apikey=rP1VDRml9KwLVg4qLpEQC4wmRoLTGoUl"
        
        print(UrlString2)
        let url2 = URL(string: UrlString2)!
        
        let task2 = session.dataTask(with: url2) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error in load2!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error in startload2 !")
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type in startLoad2!")
                return
            }
            
            do {
                var string1 = String(data: data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                print(string1)
                string1.remove(at: string1.startIndex)
                string1.remove(at: string1.index(before: string1.endIndex))
                print(string1)
                let data2: Data? = string1.data(using: .utf8)
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
 
 
    /*
 
    func startLoad3() {
        let session = URLSession.shared
        let UrlString2: String = "https://dataservice.accuweather.com/currentconditions/v1/" + locationKey + "?apikey=rP1VDRml9KwLVg4qLpEQC4wmRoLTGoUl"
        
        print(UrlString2)
        let url2 = URL(string: UrlString2)!
        
        let task2 = session.dataTask(with: url2) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error in load3!")
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
                let data2: Data? = string1.data(using: .utf8)
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
    func startLoad4() {
        print("starting startLoad4()")
        let session = URLSession.shared
        let UrlString2: String = "https://dataservice.accuweather.com/forecasts/v1/hourly/24hour/" + locationKey + "?apikey=rP1VDRml9KwLVg4qLpEQC4wmRoLTGoUl"
        
        print(UrlString2)
        let url2 = URL(string: UrlString2)!
        
        let task2 = session.dataTask(with: url2) { data, response, error in
            
            
            if error != nil || data == nil {
                print("Client error in load4!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error in startload4!")
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type in startLoad4!")
                return
            }
 
            do {
                let string1 = String(data: data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                
                let data2: Data? = string1.data(using: .utf8)
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
 
 
    
    
    //startLoad5 is for the national API weather service, which was temporarily considered for use when the other API stopped working due to a daily cap
    
    func startLoad5() {
        let session = URLSession.shared
        let UrlString: String = "https://api.weather.gov/points/" + String(latitude) + "," + String(longitude)
        
        print(UrlString)
        let url = URL(string: UrlString)!
        
        let task = session.dataTask(with: url) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error in startload5!")
                return
            }
            
            /*
            guard let mime = response.mimeType, mime == "application/json" else {
                print("Wrong MIME type in startload5!")
                return
            }
 */
 
            do {
                let string1 = String(data: data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                print(string1)
                //string1.remove(at: string1.startIndex)
                //string1.remove(at: string1.index(before: string1.endIndex))
                //print(string1)
                //var data2: Data? = string1.data(using: .utf8)
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                
                
                print("second round of api call")
                print(json ?? "did not work")
                
                
                if let properties = json?["properties"] as? [String:Any] {
                    print("properties:")
                    print(properties)
                    if let urlForAPIForecast = properties["forecastHourly"] as? String {
                        print("urlForAPIForecast:")
                        print(urlForAPIForecast)
                        self.URLForNationalWeatherServiceForecast = urlForAPIForecast
                        
                        
                    }
                    
                }
                
                
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    func startLoad6() {
        let session = URLSession.shared
     
        
        print(self.URLForNationalWeatherServiceForecast)
        if (URLForNationalWeatherServiceForecast == "") {
            print("opting out of startLoad6()")
            return
        }
        let url = URL(string: self.URLForNationalWeatherServiceForecast)!
        
        let task = session.dataTask(with: url) { data, response, error in
            
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server error in startload6 !")
                return
            }
            
            /*
             guard let mime = response.mimeType, mime == "application/json" else {
             print("Wrong MIME type in startLoad6!")
             return
             }
 */
 
            do {
                let string1 = String(data: data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
                print(string1)
                //string1.remove(at: string1.startIndex)
                //string1.remove(at: string1.index(before: string1.endIndex))
                //print(string1)
                //var data2: Data? = string1.data(using: .utf8)
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                
                
                print("second round of api call")
                print(json ?? "did not work")
                
                
                if let properties = json?["properties"] as? [String:Any] {
                    print("properties:")
                    print(properties)
                    if let urlForAPIForecast = properties["forecastHourly"] as? String {
                        print("urlForAPIForecast:")
                        print(urlForAPIForecast)
                        self.URLForNationalWeatherServiceForecast = urlForAPIForecast
                        
                        
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
        
        print("inside func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])" )
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        
        /*
         Check to see if latitutde and logitude have changed. If so make sure API hasn't been called that much. If it has, then make sure to wait a certain number of seconds by checking the timestamp before making api calls again. If it's been long enough update the timestamp to the new time
         */
        if (Double(locValue.latitude) != latitude && Double(locValue.longitude) != longitude) {
            self.latitude = locValue.latitude
            self.longitude = locValue.longitude
            //let elapsed: Double = Date().timeIntervalSince(timestamp)
            if (numberOfTimesCalledAPI <= 3) {
                print("inside locationManger, inside if latitude and logigtude has changed and number of API calls less than or equal to 3")
                startLoad()
                startLoad2()
                //startLoad3()
                startLoad4()
                startLoad5()
                startLoad6()
                numberOfTimesCalledAPI += 1;
            } else if (true){
                print(Double(timestamp) - NSDate().timeIntervalSince1970)
                
            }
                
        }
        
    
       //startLoad4()
        
 

   
    }
}

