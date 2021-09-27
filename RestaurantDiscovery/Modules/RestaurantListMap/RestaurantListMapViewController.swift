//
//  RestaurantListMapViewController.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/23/21.
//

import UIKit
import MapKit
import RxSwift
import Cosmos


class RestaurantListMapViewController: UIViewController {
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        return mapView
    }()
    
    private lazy var btnList: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("List", for: .normal)
        btn.backgroundColor = UIColor(red: 85 / 255, green: 135 / 255, blue: 45 / 255, alpha: 1)
        btn.layer.cornerRadius = 10
        btn.setImage(UIImage(named: "list24x24")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .black)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(self.btnListPressed), for: .touchUpInside)
        return btn
    }()
    
    let disposeBag = DisposeBag()
    
    var viewModel: RestaurantListViewModelType = RestaurantListViewModel(.map)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindViewModel()
        
        viewModel.input.viewDidLoad()
        
    }
    
    func makeUI() {
        self.view.addSubview(mapView)
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.register(CustomAnnotattionView.self, forAnnotationViewWithReuseIdentifier: CustomAnnotattionView.reusableIdentifier)
        if let coor = mapView.userLocation.location?.coordinate {
            mapView.setCenter(coor, animated: true)
        }
        mapView.snp.makeConstraints { maker in
            maker.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.view.addSubview(btnList)
        
        btnList.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-60)
            maker.width.equalTo(110)
            maker.height.equalTo(50)
        }
    }
    
    func bindViewModel() {
        viewModel.output.restaurants.subscribe(onNext: {
            [unowned self] items in
            self.mapView.removeAnnotations(self.mapView.annotations)
            guard !items.isEmpty else { return }
            
            let markers = items.map({ RestaurantMaker(restaurant:$0) })
            
            self.mapView.addAnnotations(markers)
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            //self.mapView.centerToLocation(CLLocation(latitude: markers.first!.coordinate.latitude, longitude: markers.first!.coordinate.longitude))
        }).disposed(by: disposeBag)
        
        viewModel.output.userLocation.subscribe(onNext: {
            [unowned self] location in
            
//            let centerLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
//            self.mapView.centerToLocation(centerLocation)
//            
//            let region = MKCoordinateRegion(
//                center: centerLocation.coordinate,
//                latitudinalMeters: 200000,
//                longitudinalMeters: 200000)
//            mapView.setCameraBoundary(
//                MKMapView.CameraBoundary(coordinateRegion: region),
//                animated: true)
//
//            let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
//            mapView.setCameraZoomRange(zoomRange, animated: true)
            
        }).disposed(by: disposeBag)
    }
    
    //MARK: - selector
    @objc func btnListPressed() {
        viewModel.input.changeToMapMode()
    }

}

extension RestaurantListMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? RestaurantMaker else {
            return nil
        }
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: CustomAnnotattionView.reusableIdentifier, for: annotation)
        view.image = UIImage(named: "pin-unselected")
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        view.image = UIImage(named: "pin-selected")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapDetail(sender:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        view.image = UIImage(named: "pin-unselected")
        view.removeGestureRecognizer(view.gestureRecognizers!.first!)
    }
    
    @objc func tapDetail(sender: UITapGestureRecognizer) {
        if let view = sender.view as? CustomAnnotattionView,
           let ann = view.annotation as? RestaurantMaker {
            self.viewModel.input.itemDidSelected(ann.restaurant)
        }
    }
}



private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 1000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

class RestaurantMaker: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    var restaurant: Restaurant
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        self.coordinate = CLLocationCoordinate2DMake(restaurant.location.latitude, restaurant.location.longitude)
    }
    
    var title: String? {
        return restaurant.name
    }
}
