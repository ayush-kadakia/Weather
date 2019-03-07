//
//  WeatherTableViewController.swift
//  Weather
//
//  Created by Ayush Kadakia on 1/18/19.
//  Copyright © 2019 Ayush Kadakia. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

struct Weather: Decodable {
    let currently: Currently
    let daily: Daily
}

struct Currently: Decodable {
    let summary: String
    let icon: String
    let temperature: Double
}

struct Daily: Decodable {
    let data: [dayData]
}

struct dayData: Decodable {
    let icon: String
    let summary: String
    let temperatureHigh: Double
    let temperatureLow: Double
    let time: Double
}

class WeatherTableViewController: UITableViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var Lat = Double()
    var Long = Double()
    var CityName = String()

    
    let locationManager = CLLocationManager()
    var forecastData: [dayData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.requestLocation()
        
        
    }
    

    
    func updateWeather(uno: Double, dos: Double) {
        let jsonURLString = "https://api.darksky.net/forecast/6a55d0a46927c29ca46e3ceaef87e919/\(uno),\(dos)"
        
        guard let URL = URL(string: jsonURLString) else { return }
        
        URLSession.shared.dataTask(with: URL) { (data, response, error) in
            
            guard let data = data else { return }
            
            do{
                let weatherData = try JSONDecoder().decode(Weather.self, from: data)
                self.forecastData = weatherData.daily.data
                print(self.forecastData[1].summary)
                DispatchQueue.main.async {
                    self.navigationItem.title = "Currently: \(weatherData.currently.temperature)°F"
                    self.tableView.reloadData()
                }
                
            } catch{
                print(error)
            }
            }.resume()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let locationString = searchBar.text, !locationString.isEmpty{
            
            getCoordinateFrom(address: locationString) { coordinate, error in
                guard let coordinate = coordinate, error == nil else { return }
                DispatchQueue.main.async {
                    print(coordinate)
                    self.updateWeather(uno: coordinate.latitude, dos: coordinate.longitude)
                }
                
            }
        }
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
        CLGeocoder().geocodeAddressString(address) { placemarks, error in
            completion(placemarks?.first?.location?.coordinate, error)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude {
            print("\(lat),\(long)")

            self.Lat = lat
            self.Long = long
            
        } else {
            print("No coordinates")
            self.Lat = 42.3601
            self.Long = -71.0589
        }
        
        updateWeather(uno: Lat, dos: Long)

        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return forecastData.count
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath)

        let weatherObject = forecastData[indexPath.row]
        
        let date = Date(timeIntervalSince1970: weatherObject.time)
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEEMMMMd")
            
        cell.textLabel?.text = "\(dateFormatter.string(from: date)):   "
        cell.detailTextLabel?.text = "Low: \(weatherObject.temperatureLow)°F \nHigh: \(weatherObject.temperatureHigh)°F \nSummary: \(weatherObject.summary)"
        cell.imageView?.image = UIImage(named: weatherObject.icon)

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
