//
//  CustomAnnotattionView.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/26/21.
//

import MapKit
import Cosmos

class CustomAnnotattionView: MKAnnotationView {
    private lazy var imageViewRestaurant: UIImageView = {
        let imageView = UIImageView(frame: .init(x: 0, y: 0, width: 70, height: 70))
        return imageView
    }()
    
    private lazy var ratingView: CosmosView = {
        let ratingView = CosmosView()
        ratingView.isUserInteractionEnabled = false
        ratingView.text = "(145)"
        return ratingView
    }()
    
    private lazy var lblSubTitle: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .black)
        lbl.textColor = .secondaryLabel
        lbl.text = "$$$ . Supporting Text"
        return lbl
    }()
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        guard let annotation = annotation as? RestaurantMaker else { return }

        if let strUrl = annotation.restaurant.photoURL,
           let url = URL(string: strUrl) {
            self.imageViewRestaurant.sd_setImage(with: url, completed: nil)
        }

        self.ratingView.rating = annotation.restaurant.rating
        self.lblSubTitle.text = annotation.restaurant.priceLevel.repeating("$") + ". Supporting Text"
        self.ratingView.text = "(\(annotation.restaurant.userRatingsTotal))"
    }
    
    func makeUI() {
        self.image = UIImage(named: "pin-unselected")
        
        self.canShowCallout = true
   
        self.leftCalloutAccessoryView = imageViewRestaurant

        let detailView = UIView()
        self.detailCalloutAccessoryView = detailView
        detailView.snp.makeConstraints { maker in
            maker.width.equalTo(150)
            maker.height.equalTo(40)
        }

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        detailView.addSubview(stackView)
        stackView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        stackView.addArrangedSubview(self.ratingView)
        stackView.addArrangedSubview(self.lblSubTitle)
    }
}

extension CustomAnnotattionView: Reusable {}
