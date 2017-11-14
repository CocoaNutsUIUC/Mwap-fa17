//
//  ViewController.swift
//  Mwap
//
//  Created by Justin Loew on 1/16/17.
//  Copyright © 2017 Justin Loew. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var locationLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// Disable scrolling and zooming the map, since we don't have a button
		// to re-center the map on the user's current location.
		mapView.isZoomEnabled = false
		mapView.isScrollEnabled = false
		mapView.isRotateEnabled = false
		mapView.isPitchEnabled = false
		
		// Set up the map view to show the user's location.
		mapView.showsUserLocation = true
		mapView.userTrackingMode = .followWithHeading
		
		// Set the map view's delegate.
		mapView.delegate = self
	}
	
	private let locationManager = CLLocationManager()
	override func viewDidAppear(_ animated: Bool) {
		// Request permission to use the user's location.
		locationManager.requestWhenInUseAuthorization()
	}
	
	// Update the printed location on screen based on a user's location.
	func updateLocationLabel(for userLocation: MKUserLocation) {
		// Make sure we have a valid location.
		guard let location = userLocation.location else {
			locationLabel.text = "Unable to determine location."
			return
		}
		
		// For these descriptions, type `±' with option-shift-+ and type `˚' (degree symbol) with option-k
		
		// Get GPS coordinates, altitude, speed, and heading.
		let gpsDescription: String
		let altitudeDescription: String
		let speedDescription: String
		let headingDescription: String
		let orientationDescription: String
		let lastUpdatedDescription: String
		
		/// Pretty print a number by trimming off excess decimal points.
		func pretty(_ n: Double, numDigits: Int = 2) -> String {
			// Set up a number formatter to pretty print these numbers.
			let fmt = NumberFormatter()
			fmt.maximumFractionDigits = numDigits
			// Apply the number formatter to the number.
			return fmt.string(from: NSNumber(value: n))!
		}
		/// Pretty print a date.
		func pretty(_ date: Date) -> String {
			// Set up a date formatter to pretty print the date.
			let fmt = DateFormatter()
			fmt.dateStyle = .short
			fmt.timeStyle = .medium
			// Apply the date formatter to the date.
			return fmt.string(from: date)
		}
		
		let coords = location.coordinate
		gpsDescription = "<\(pretty(coords.latitude, numDigits: 5)), \(pretty(coords.longitude, numDigits: 5))> ± \(Int(location.horizontalAccuracy)) m"
		
    let FEET_PER_METER = 3.281
		altitudeDescription = "\(pretty(location.altitude)) m ± \(Int(location.verticalAccuracy)) m (\(Int(location.altitude * FEET_PER_METER))' ± \(Int(location.verticalAccuracy * FEET_PER_METER))')"
		
		// Handle the speed.
		if location.speed >= 0 {
			// Convert m/s to mph to figure out the speed.
			let MPH_PER_MS = 2.23694
			let speed_mph = location.speed * MPH_PER_MS
			speedDescription = "\(pretty(location.speed)) m/s (\(pretty(speed_mph)) mph)"
		} else {
			// Invalid speed.
			speedDescription = "Unknown"
		}
		
		// Heading is the direction in which the device is traveling.
		if location.course >= 0 {
			headingDescription = "\(pretty(location.course, numDigits: 1))˚"
		} else {
			// Invalid heading.
			headingDescription = "Unknown"
		}
		
		// Get the device orientation (which way the device is pointing).
		if let deviceHeading = userLocation.heading,
			deviceHeading.headingAccuracy >= 0
		{
			orientationDescription = "\(pretty(deviceHeading.trueHeading, numDigits: 1))˚ ± \(pretty(deviceHeading.headingAccuracy, numDigits: 1))˚"
		} else {
			orientationDescription = "Unknown"
		}
		
		lastUpdatedDescription = "\(pretty(location.timestamp))"
		
		// Combine the various descriptions and make them look nice.
		let descriptions = [
			"Location:     \(gpsDescription)",
			"Altitude:     \(altitudeDescription)",
			"Speed:        \(speedDescription)",
			"Heading:      \(headingDescription)",
			"Orientation:  \(orientationDescription)",
			"Last Updated: \(lastUpdatedDescription)",
		]
		let completeDescription = descriptions.joined(separator: "\n")
		
		// Finally, put the new description on screen.
		locationLabel.text = completeDescription
	}

}

extension ViewController: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		// This function gets called every time the user's location changes.
		updateLocationLabel(for: userLocation)
	}
	
	func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
		print(error)
	}
	
}
