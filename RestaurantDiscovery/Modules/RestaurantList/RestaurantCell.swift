//
//  RestaurantCell.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/21/21.
//

import UIKit
import Cosmos
import SDWebImage
import FaveButton

class RestaurantCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.addShadow(offset: CGSize(width: 0, height: 2), opacity: 0.4, radius: 10, color: .lightGray)
        containerView.backgroundColor = .white
        return containerView
    }()
    private lazy var lblName: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .black)
        lbl.textColor = .label
        lbl.text = "Name"
        return lbl
    }()
    
    private lazy var ratingView: CosmosView = {
        let ratingView = CosmosView()
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
    
    
    private lazy var imageViewRestaurant: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private lazy var btnLike: FaveButton = {
        let btn = FaveButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30), faveIconNormal: UIImage(named: "heart"))
        
        return btn
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        self.selectionStyle = .none
        self.contentView.addSubview(containerView)
        self.contentView.backgroundColor = .systemGroupedBackground
        containerView.snp.makeConstraints { maker in
            maker.leading.top.equalToSuperview().offset(5)
            maker.trailing.bottom.equalToSuperview().offset(-5)
        }
        
        containerView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { maker in
            maker.leading.top.equalToSuperview().offset(20)
            maker.trailing.bottom.equalToSuperview().offset(-20)
        }
        
        contentStackView.addArrangedSubview(imageViewRestaurant)
        contentStackView.addArrangedSubview(rightStackView)
        
        rightStackView.addArrangedSubview(lblName)
        rightStackView.addArrangedSubview(ratingView)
        rightStackView.addArrangedSubview(lblSubTitle)
        
        imageViewRestaurant.snp.makeConstraints { maker in
            maker.width.equalTo(imageViewRestaurant.snp.height)
        }
        
        imageViewRestaurant.sd_setImage(with: URL(string: "https://picsum.photos/200/300")!, completed: nil)
        
        self.contentView.addSubview(btnLike)
        
        btnLike.snp.makeConstraints { maker in
            maker.top.equalToSuperview().offset(20)
            maker.trailing.equalToSuperview().offset(-20)
            maker.width.height.equalTo(30)
        }
    }
    
    
}

extension RestaurantCell: Resuable {}
