//
//  SectionHeaderView.swift
//  NetflixClone
//
//  Created by 내일배움캠프 on 12/24/24.
//
import UIKit
import SnapKit

final class SectionHeaderView: UICollectionReusableView {
    static let id = "SectionHeaderView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview().offset(10)
            make.top.bottom.equalToSuperview().offset(5)
        }
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
