//
//  ViewController.swift
//  Album
//
//  Created by Ihwan on 18/03/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: [UIImage] = []{
        didSet {
            guaranteeMainThread {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        navigationController?.navigationBar.backgroundColor = .blue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addDefaultImage()
        addDefaultImage()
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        showSimpleActionSheet()
    }
    
    private func addDefaultImage() {
        for i in 1...7 {
            images.append(UIImage(named: "\(i)")!)
        }
    }
    
    func showSimpleActionSheet() {
        let alert = UIAlertController(title: "Add a photo", message: "Please Select an option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "From photo library", style: .default, handler: { (_) in
            self.getImage(fromSourceType: .photoLibrary)
        }))

        alert.addAction(UIAlertAction(title: "Open camera app", style: .default, handler: { (_) in
            self.getImage(fromSourceType: .camera)
        }))

        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))

        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    func didFinishPickingPicture(_ image: UIImage) {
        images.append(image)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.bounds.width / 3.0 - 16
        let height = width

        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumCollectionViewCell
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            didFinishPickingPicture(image)
             } else if let image = info[.originalImage] as? UIImage {
            didFinishPickingPicture(image)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
         } else {
            print("Source type isn't available")
         }
    }
}
