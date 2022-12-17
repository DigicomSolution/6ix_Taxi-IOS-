//
//  GMSMapView.swift
//  User
//
//  Created by CSS on 17/02/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import GoogleMaps

private struct MapPath : Decodable{
    
    var routes : [Route]?
    
}

private struct Route : Decodable{
    
    var overview_polyline : OverView?
    var legs : [LegsObject]?
}

private struct OverView : Decodable {
    
    var points : String?
}

private struct LegsObject : Decodable {
    var duration : DurationObject?
}

private struct DurationObject : Decodable {
    var text : String?
}

extension GMSMapView {
    
    
    //MARK:- Call API for polygon points
    
    func drawPolygon(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
       
        self.getGoogleResponse(between: source, to: destination) { (mapPath) in
            if let points = mapPath.routes?.first?.overview_polyline?.points {
//                DispatchQueue.main.async {
//                    Global.shared.polyline.map = nil
//                }
                
                self.drawPath(with: points)

            }
        }
    }
    
    
    // MARK;- Get estimation between coordinates
    
    func getEstimation(between source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion : @escaping((String)->Void)) {
        self.getGoogleResponse(between: source, to: destination) { (mapPath) in
            if let estimationString = mapPath.routes?.first?.legs?.first?.duration?.text {
                completion(estimationString)
            }
        }
    }
    
    // Get response Between Coordinates
    private func getGoogleResponse(between source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion : @escaping((MapPath)->Void)) {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(googleMapKey)") else {
            return
        }
       // self.showToast(string: "TOAST YPUSAF")

        
     //   print("Yes It is")
    
       // Drawing the path
        DispatchQueue.main.async {

            session.dataTask(with: url) { (data, response, error) in
             //  print("Inside Polyline ", data != nil)
                guard data != nil else {
                    return
                }

                do {
                    let parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
                    print(parsedResult)

                    let mapPath = try JSONDecoder().decode(MapPath.self, from: data!)
                     completion(mapPath)
                   // print("Routes === \(mapPath.routes!)")
                    print(mapPath.routes?.first?.overview_polyline?.points as Any)

                } catch let error {

                    print("Failed to draw ",error.localizedDescription)
                }

                }.resume()
        }
        
        //Add Comment till here
    }
    
    
    
    private func showToast(string : String?) {
        
        self.makeToast(string, point: CGPoint(x: UIScreen.main.bounds.width/2 , y: UIScreen.main.bounds.height/2), title: nil, image: nil, completion: nil)
        
    }
    
    //MARK:- Draw polygon
    
    private func drawPath(with points : String){
        
       // print("Drawing Polyline ", points)
        
        DispatchQueue.main.async {
        
            guard let path = GMSPath(fromEncodedPath: points) else { return }
            Global.shared.polyline = GMSPolyline(path: path)
            polyLinePath = Global.shared.polyline
            Global.shared.polyline.strokeWidth = 3.0
            Global.shared.polyline.strokeColor = .primary
            Global.shared.polyline.map = self
            var bounds = GMSCoordinateBounds()
            for index in 1...path.count() {
                bounds = bounds.includingCoordinate(path.coordinate(at: index))
            }
            self.animate(with: .fit(bounds))
        }
        
    }
 
}


