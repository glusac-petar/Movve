//
//  MPosterTableViewCell.swift
//  Movve
//
//  Created by Petar Glusac on 23.3.21..
//

import UIKit

protocol MPosterTableViewCellDelegate: class {
    func didSelectItemAt(indexPath: IndexPath)
}

class MPosterTableViewCell: UITableViewCell {
    
    static let reuseID = "MPosterTableViewCell"
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private weak var delegate: MPosterTableViewCellDelegate!
    private var data: [BasicResult] = []
    private var section: Int!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubviews(collectionView)
        
        collectionView.register(MPosterCollectionViewCell.self, forCellWithReuseIdentifier: MPosterCollectionViewCell.reuseID)
        (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func set(data: [BasicResult], section: Int, delegate: MPosterTableViewCellDelegate) {
        self.data = data
        self.section = section
        self.delegate = delegate
        self.collectionView.reloadDataOnMainThread()
    }
    
}

extension MPosterTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return data.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MPosterCollectionViewCell.reuseID, for: indexPath) as! MPosterCollectionViewCell
        cell.set(path: data[indexPath.item].posterPath!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height * 0.75, height: collectionView.bounds.height)
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.didSelectItemAt(indexPath: IndexPath(item: indexPath.item, section: section))
    }
    
}
