//
//  Artwork.swift
//  Oasis
//
//  Created by WU Yifan on 6/10/22.
//

import Foundation
import UIKit
import MapKit

class Artwork: NSObject, MKAnnotation {
    let title: String?
    let locationName: String?
    let discipline: String?
    let coordinate: CLLocationCoordinate2D
    
    var markerTintColor: UIColor  {
      switch discipline {
      case "1":
          return UIColor.MyTheme.pink1
      case "2":
          return UIColor.MyTheme.green1
      case "3":
        return UIColor.MyTheme.purple2
      case "4":
          return UIColor.MyTheme.blue1
      case "5":
        return UIColor.MyTheme.orange
      case "6":
          return UIColor.MyTheme.red
      case "7":
        return UIColor.MyTheme.pink2
      case "8":
        return UIColor.MyTheme.green4
      case "9":
        return UIColor.MyTheme.blue2
      case "0":
          return UIColor.MyTheme.green3
      default:
          return UIColor.red
      }
    }

    init(title: String?, locationName: String?, discipline: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        super.init()
    }

    var subtitle: String? {
        return locationName
    }
}

class ArtworkMarkerView: MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      // 1
      guard let artwork = newValue as? Artwork else {
        return
      }
      canShowCallout = true
      calloutOffset = CGPoint(x: -5, y: 5)
      rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

      // 2
      markerTintColor = artwork.markerTintColor
      if let letter = artwork.discipline?.first {
        glyphText = String(letter)
      }
    }
  }
}
