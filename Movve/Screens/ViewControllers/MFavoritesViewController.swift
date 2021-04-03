//
//  MFavoritesViewController.swift
//  Movve
//
//  Created by Petar Glusac on 27.3.21..
//

import UIKit

class MFavoritesViewController: UIViewController {
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var favorites: [Favorite] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        configureCollectionView()
        layoutUI()
        createLongPressGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    private func configureViewController() { view.backgroundColor = .mBackground }
    
    private func configureCollectionView() {
        collectionView.register(MPosterCollectionViewCell.self, forCellWithReuseIdentifier: MPosterCollectionViewCell.reuseID)
        collectionView.backgroundColor = .mBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func fetchData() {
        showLoadingScreen()
        PersistenceManager.retrieveFavorites { [weak self] (data) in
            guard let self = self else { return }
            self.favorites = data
            self.collectionView.reloadDataOnMainThread()
            self.dismissLoadingScreen()
        }
    }

    private func createLongPressGestureRecognizer() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPress.minimumPressDuration = 0.5
        collectionView.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != .began { return }
        if let indexPath = collectionView.indexPathForItem(at: gestureRecognizer.location(in: collectionView)) { presentActionSheetForCellAt(indexPath: indexPath) }
    }
    
    private func presentActionSheetForCellAt(indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Remove from favorites", style: .destructive, handler: { [weak self] (_) in
            guard let self = self else { return }
            self.removeFromFavorites(indexPath: indexPath)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func removeFromFavorites(indexPath: IndexPath) {
        PersistenceManager.updateWith(favorite: favorites[indexPath.item], actionType: .remove) { [weak self] (error) in
            guard let self = self else { return }
            
            guard let error = error else {
                let title = self.favorites[indexPath.item].title
                self.favorites.remove(at: indexPath.item)
                self.collectionView.reloadDataOnMainThread()
                self.presentAlert(title: "Success!", message: "\(title) has been removed from your favorites list 😞.")
                return
            }
            self.presentAlert(title: "Woops!", message: error.rawValue)
        }
    }
    
}

extension MFavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { return favorites.count }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MPosterCollectionViewCell.reuseID, for: indexPath) as! MPosterCollectionViewCell
        cell.set(path: favorites[indexPath.item].posterPath!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.width - 24
        let itemWidth = (availableWidth - 20)/3
        
        return CGSize(width: itemWidth, height: itemWidth/0.75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { return 10 }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = favorites[indexPath.item]
        navigationItem.backButtonTitle = "Back"
        navigationController?.pushViewController(MDetailsViewController(type: selectedItem.type, id: selectedItem.id), animated: true)
    }
    
}
