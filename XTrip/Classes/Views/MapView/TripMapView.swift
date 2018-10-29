//
//  TripMapView.swift
//  XTrip
//
//  Created by Khoa Bui on 12/4/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit
import MapKit

protocol TripMapViewDelegate: class {
    func didTapAnntatioCountry(tripMapView: TripMapView, atTripId tripId: Int, friendInfo: TDUser?, andCountryCode countryCode: String?, coordinate: CLLocationCoordinate2D, andCountryName countryName: String?, andCityId cityId: Int?, andCityName cityName: String?)
}

class TripMapView: UIView {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailPlaceLabel: UILabel!
    @IBOutlet weak var detailPlaceView: UIView!
    
    var scheduleArray : [TDSchedule]?
    var tripCityArray : [TDTripCity]?
    var tripData: TDTrip?
    var locations: [CLLocationCoordinate2D] = []
    weak var tripMapViewDelegate: TripMapViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.mapView.delegate = self
        
    }
    
    func setCountryTripData(scheduleArray: [TDSchedule]?, tripData: TDTrip?) {
        self.scheduleArray = scheduleArray
        self.tripData = tripData
        self.locations = []
        self.removeAllAnnotation()
        if let scheduleArray = scheduleArray {
            for schedule in scheduleArray {
                if let lat = schedule.lat,
                    let latDouble = Double(lat),
                    let long = schedule.long,
                    let longDouble = Double(long),
                    let countryCode = schedule.countryCode,
                    let countryName = schedule.countryName,
                    let tripId = tripData?.tripId {
                    let point = CountryAnnotation(tripId: tripId, coordinate: CLLocationCoordinate2D(latitude: latDouble , longitude: longDouble), countryCode: countryCode, countryName: countryName, cityId: nil, cityName: nil)
                    self.mapView.addAnnotation(point)
                    self.mapView.showAnnotations(mapView.annotations, animated: false)
                    // Provide location to draw route
                    self.locations.append(CLLocationCoordinate2D(latitude: latDouble, longitude: longDouble))
                }
            }
            if scheduleArray.count == 1 {
                let latitude:CLLocationDegrees = Double(scheduleArray.first?.lat ?? "0.0")!
                let longitude:CLLocationDegrees = Double(scheduleArray.first?.long ?? "0.0")!
                let latDelta:CLLocationDegrees = 100
                let lonDelta:CLLocationDegrees = 100
                let span = MKCoordinateSpanMake(latDelta, lonDelta)
                let location = CLLocationCoordinate2DMake(latitude, longitude)
                let region = MKCoordinateRegionMake(location, span)
                mapView.setRegion(region, animated: false)
            }
            // Draw route
            self.creatingPolylines(locations: self.locations)
        }
        // Load day count for country
        self.setDetailPlaceLabel(scheduleArray: scheduleArray, tripCityArray: nil)
        self.mapView.fitAll()
    }
    
    func setCityTripData(tripCityArray: [TDTripCity]?, currentCountryCodinate: CLLocationCoordinate2D) {
        self.tripCityArray = tripCityArray
        self.locations = []
        self.removeAllAnnotation()
        if tripCityArray?.count == 0 || tripCityArray == nil {
            let latDelta:CLLocationDegrees = 10
            let lonDelta:CLLocationDegrees = 10
            let span = MKCoordinateSpanMake(latDelta, lonDelta)
            let region = MKCoordinateRegionMake(currentCountryCodinate, span)
            mapView.setRegion(region, animated: false)
        }
        if let tripCityArray = tripCityArray {
            for tripCity in tripCityArray {
                if let lat = tripCity.lat,
                    let latDouble = Double(lat),
                    let long = tripCity.long,
                    let longDouble = Double(long),
                    let cityName = tripCity.name,
                    let cityId = tripCity.id,
                    let tripId = tripCity.tripId{
                    let point = CountryAnnotation(tripId: tripId, coordinate: CLLocationCoordinate2D(latitude: latDouble , longitude: longDouble), countryCode: nil, countryName: nil, cityId: cityId, cityName: cityName)
                    self.mapView.addAnnotation(point)
                    self.mapView.showAnnotations(mapView.annotations, animated: false)
                    // Provide location to draw route
                    self.locations.append(CLLocationCoordinate2D(latitude: latDouble, longitude: longDouble))
                }
            }
            if tripCityArray.count == 1 {
                let latitude:CLLocationDegrees = Double(tripCityArray.first?.lat ?? "0.0")!
                let longitude:CLLocationDegrees = Double(tripCityArray.first?.long ?? "0.0")!
                let latDelta:CLLocationDegrees = 10
                let lonDelta:CLLocationDegrees = 10
                let span = MKCoordinateSpanMake(latDelta, lonDelta)
                let location = CLLocationCoordinate2DMake(latitude, longitude)
                let region = MKCoordinateRegionMake(location, span)
                mapView.setRegion(region, animated: false)
            }
            // Draw route
            self.creatingPolylines(locations: self.locations)
        } else {
            
        }
        // Load day count for city
        self.setDetailPlaceLabel(scheduleArray: nil, tripCityArray: tripCityArray)
        if tripCityArray?.count != 0  {
            self.mapView.fitAll(isCountryLevel: false);
        }
    }
    
    func setDetailPlaceLabel(scheduleArray: [TDSchedule]?, tripCityArray: [TDTripCity]?) {
        self.detailPlaceLabel.text = ""
        if let scheduleArray = scheduleArray {
            var countryDay = ""
            for (index, schedule) in scheduleArray.enumerated() {
                guard let countryName = schedule.countryName else {return}
                guard let dayCount = schedule.days else {return}
                countryDay += (index == 0 ? "" : "\n") + countryName + " : " + "\(dayCount)" + (dayCount > 1 ? " days " : " day ")
            }
            self.detailPlaceView.isHidden = scheduleArray.count == 0 ? true : false
            self.detailPlaceLabel.text = countryDay
        } else if let tripCityArray = tripCityArray {
            var cityDay = ""
            for (index, tripCity) in tripCityArray.enumerated() {
                guard let startDateUnix = tripCity.startDate else {return}
                guard let endDateUnix = tripCity.endDate else {return}
                guard let cityName = tripCity.name else {return}
                var dayCount: Int?
                if endDateUnix == startDateUnix {
                    dayCount = 1
                } else {
                    dayCount = Ultilities.getDaysFromTwoDates(startDateUnix: startDateUnix, endDateUnix: endDateUnix)
                }
                cityDay += (index == 0 ? "" : "\n") + cityName + " : " + "\(dayCount ?? 0)" + (dayCount ?? 0 > 1 ? " days " : " day ")
            }
            self.detailPlaceView.isHidden = tripCityArray.count == 0 ? true : false
            self.detailPlaceLabel.text = cityDay
        }
    }
    
    fileprivate func removeAllAnnotation() {
        self.mapView.removeAnnotations(self.mapView.annotations)
        for overlay in self.mapView.overlays {
            self.mapView.remove(overlay)
        }
    }
    
    fileprivate func creatingPolylines(locations: [CLLocationCoordinate2D]) {
        if locations.count >= 2 {
            let geodesicPolyline = MKGeodesicPolyline(coordinates: self.locations, count: self.locations.count)
            self.mapView?.add(geodesicPolyline)
        }
    }
}

extension TripMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        annotationView.canShowCallout = false
        annotationView.annotation = annotation
        annotationView.image = #imageLiteral(resourceName: "trip_annotation")
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.mapView.deselectAnnotation(view.annotation, animated: true)
        // 1
        if view.annotation is MKUserLocation
        {
            // Don't proceed with custom callout
            return
        }
        // 2
        let countryAnnotation = view.annotation as! CountryAnnotation
        self.tripMapViewDelegate?.didTapAnntatioCountry(tripMapView: self, atTripId: countryAnnotation.tripId, friendInfo: self.tripData?.friend, andCountryCode: countryAnnotation.countryCode, coordinate: countryAnnotation.coordinate, andCountryName: countryAnnotation.countryName, andCityId: countryAnnotation.cityId, andCityName: countryAnnotation.cityName)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer()
        }
        
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 2.0
        renderer.strokeColor = UIColor.init(hex: "30B3FF")
        
        return renderer
    }
}

extension MKMapView {
    /// when we call this function, we have already added the annotations to the map, and just want all of them to be displayed.
    // isCountryLevel: Map will zoom to fit country
    func fitAll(isCountryLevel countryLevel: Bool = true) {
        var zoomRect            = MKMapRectNull;
        for annotation in annotations {
            let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect       = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.01, 0.01);
            zoomRect            = MKMapRectUnion(zoomRect, pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsetsMake(20, 20, 20, 20), animated: false)
        
        //After map is set, check if all annotations are shown, if not -> Focus on the last annotation (do the same for the case when there is only 1 annotation). ONLY HANDLE FOR COUNTRY LEVEL ANNOTATION
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
                let visibleAnnotations = self.annotations(in: self.visibleMapRect);
                if (visibleAnnotations.count != self.annotations.count ||  self.annotations.count == 1) {
                    //                self.showAnnotations([self.annotations.last!], animated: true);
                    let lastAnnotation = self.annotations.last!;//Unwrapping is safe because annotations must be available due to the self.annotations.count in the if statement
                    
                    var mapRegion = MKCoordinateRegion();
                    mapRegion.center = lastAnnotation.coordinate;
                    //Set the zoom level so that the whole country can possibly be shown in case of country level
                    if (countryLevel) {
                    mapRegion.span.latitudeDelta = 50;
                    mapRegion.span.longitudeDelta = 50;
                    } else {//Set the value of delta = 5 for city level
                        mapRegion.span.latitudeDelta = 3;
                        mapRegion.span.longitudeDelta = 3;
                    }
                    self.setRegion(mapRegion, animated: false);
                    print("Map region set");
                }
            })
        
    }
    
    /// we call this function and give it the annotations we want added to the map. we display the annotations if necessary
    func fitAll(in annotations: [MKAnnotation], andShow show: Bool) {
        var zoomRect:MKMapRect  = MKMapRectNull
        
        for annotation in annotations {
            let aPoint          = MKMapPointForCoordinate(annotation.coordinate)
            let rect            = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        if(show) {
            addAnnotations(annotations)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }
    
}

