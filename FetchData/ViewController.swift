//
//  ViewController.swift
//  FetchData
//
//  Created by Roydon Jeffrey on 12/8/16.
//  Copyright © 2016 Italyte. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var message: UILabel!
    @IBOutlet var timestamp: UILabel!
    @IBOutlet var latitude: UILabel!
    @IBOutlet var longitude: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        fetchData() { result in
            self.message.text = result?.message
            self.timestamp.text = result?.timeStamp
            self.latitude.text = result?.coordinate.lat
            self.longitude.text = result?.coordinate.long
        }
        
    }
    
    struct Coordinate {        
        var lat: String
        var long: String
    }
    
    class Position {
        var message: String
        var timeStamp: String
        var coordinate: Coordinate
        
        init(jsonOject: [String: Any]) {
            
            self.timeStamp = "\(jsonOject["timestamp"]!)"
            self.message = jsonOject["message"] as? String ?? "unknown"
            let position = jsonOject["iss_position"] as? [String: Any]
            let lat = position?["latitude"] as? String ?? "unknown"
            let long = position?["longitude"] as? String ?? "unknown"
            self.coordinate = Coordinate(lat: lat, long: long)
        }
    }
    
    func parseJSON(data: Data, completionHandler1: @escaping (Position?)->()) {
        var position: Position? = nil
        if let jsonObject = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any] {
            position = Position(jsonOject: jsonObject)
        }
        
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                completionHandler1(position)
            }
        }
    }
    
    func fetchData(completionHandler2: @escaping (Position?)->()) {
        let url = URL(string: "http://api.open-notify.org/iss-now.json")!
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let responseData = data else {
                completionHandler2(nil)
                return
            }
            
            print(Thread.isMainThread)
            
            self.parseJSON(data: responseData, completionHandler1: completionHandler2)
            }.resume()
    }

}

