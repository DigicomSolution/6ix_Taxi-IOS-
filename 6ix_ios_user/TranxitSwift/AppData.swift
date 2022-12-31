//
//  AppData.swift
//  User
//
//  Created by CSS on 10/01/18.
//  Copyright © 2018 Appoets. All rights reserved.
//
/*let appSecretKey = "490fce41e03bcbca899147e7507112c9"
let appClientId = 503449377809300*/
import UIKit

let userDefault = UserDefaults.standard
let AppName = "6ix Taxi"
var deviceTokenString = Constants.string.noDevice
let googleMapKey = "AIzaSyDyn0l-4-daP476zj5wlVCvn7oi3fFgT7Q"//"AIzaSyDZE-1-gX5j7eQt5RxzuOAMnOs2YMmTgXo"

//"AIzaSyCdP7OZb7vO8xVxc4mMvwh24O8mz45nVys"

//"AIzaSyDZE-1-gX5j7eQt5RxzuOAMnOs2YMmTgXo"
    
//"AIzaSyCxS2tj5dBdV50bWpvt2_bIC33nTyo5Z9o" //"AIzaSyBDk13M3Mu9dAapi3IjgPcsbc6ZhD1yt84"//"AIzaSyBm__ycW-Bx_MWf0cF-lbByVfWptnXNTXM"
//"AIzaSyBkp6SenausSNP6F3v4pwkfg0cnbRCRQuE"//"AIzaSyCgoZk9_bfeFYXXG93StvOVzHWJKjbjw1I"//"AIzaSyCdP7OZb7vO8xVxc4mMvwh24O8mz45nVys"//"AIzaSyAdOuzl9S6Ve4WNmlGS5nPK8SPuOA9qjic"//"AIzaSyCdP7OZb7vO8xVxc4mMvwh24O8mz45nVys"
let appSecretKey = "vNL65HPbu7oMeZq4H0Ps26gOQdr3UTfcFUjkNPGB"
let appClientId = 2


let defaultMapLocation = LocationCoordinate(latitude: 43.651070, longitude: -79.347015)
//let locationApi = "https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@"
//let baseUrl = "https://stagging.6ixtaxi.com"//"https://6ixtaxi.com"
//let baseUrlStaging = "https://l7-stagging.6ixtaxi.com"//"https://6ixtaxi.com"


let baseUrl = "https://6ixtaxi.com" //"https://6ixtaxi.com"
let baseUrlStaging = "http://l7.6ixtaxi.com"       //"https://l7.6ixtaxi.com"

let passwordLengthMax = 10
//let distanceType = "km"
let requestCheckInterval : TimeInterval = 5
//var sosNumber = 911

var supportNumber = "+923155163189"
var supportEmail = "qaisarayub2009@gmail.com"
var offlineNumber = "+923335179003"
let stripePublishableKey = "pk_live_lqMVZCRgbo5Oru7K9GVxMSoE00hwdhnMPn"//"pk_test_0G4SKYMm8dK6kgayCPwKWTXy"
let helpSubject = "\(AppName) Help"
let driverUrl = "https://apps.apple.com/pk/app/6ix-taxi-driver/id1450482019"
let requestInterval : TimeInterval = 60  // seconds
