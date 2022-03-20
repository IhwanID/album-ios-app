//
//  ViewController.swift
//  Album
//
//  Created by Ihwan on 18/03/22.
//

import UIKit
import MobileCoreServices
import AVFoundation
import CoreMedia
import AVKit



class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var album: [Album] = []{
        didSet {
            guaranteeMainThread {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDefaultImage()
        collectionView.delegate = self
        collectionView.dataSource = self
        setupLongGestureRecognizerOnCollection()
        
        navigationController?.navigationBar.backgroundColor = UIColor(hex: "#2962ffff")
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        showSimpleActionSheet()
    }
    
    private func addDefaultImage() {
        for i in 1...7 {
            let image = Album(image: UIImage(named: "\(i)")!, isVideo: false, video: nil)
            album.append(image)
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
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func didFinishPickingPicture(_ image: UIImage, _ isVideo: Bool = false, _ video: URL? = nil) {
        let data = Album(image: image, isVideo: isVideo, video: video)
        album.append(data)
    }
    
    private func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delaysTouchesBegan = true
        collectionView?.addGestureRecognizer(longPressedGesture)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }
        
        let index = gestureRecognizer.location(in: collectionView)
        
        if let indexPath = collectionView?.indexPathForItem(at: index) {
            let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                self.album.remove(at: indexPath.row)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            
            self.present(dialogMessage, animated: true, completion: nil)
            
        }
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if album[indexPath.row].isVideo {
            
            let videoURL = album[indexPath.row].video!
            
            let player = AVPlayer(url: videoURL as URL)
            let controller = AVPlayerViewController()
            controller.player = player
            present(controller, animated: true) {
                player.play()
            }
        } else {
            let newImageView = UIImageView(image: album[indexPath.row].image)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            let pinchMethod = UIPinchGestureRecognizer(target: self, action: #selector(pinchImage(sender:)))
            newImageView.addGestureRecognizer(pinchMethod)
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    @objc func pinchImage(sender: UIPinchGestureRecognizer) {
        
        if let scale = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)) {
            guard scale.a > 1.0 else { return }
            guard scale.d > 1.0 else { return }
            sender.view?.transform = scale
            sender.scale = 1.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.width / 3.0 - 16
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumCollectionViewCell
        cell.imageView.image = album[indexPath.item].image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[.mediaType] as! CFString
        switch mediaType {
        case kUTTypeImage:
            if let image = info[.editedImage] as? UIImage {
                didFinishPickingPicture(image)
            } else if let image = info[.originalImage] as? UIImage {
                didFinishPickingPicture(image)
            }
        case kUTTypeMovie:
            let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            let image = extractFirstFrame(url: videoUrl)
            didFinishPickingPicture(image, true, videoUrl)
        default:
            let alert = UIAlertController(title: "Error", message: "Mismatched type: \(mediaType)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func getImage(fromSourceType sourceType: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Error", message: "Source type isn't available", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func extractFirstFrame (url: URL) -> UIImage
    {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator.init(asset: asset)
        let cgImage = try! generator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        return  UIImage(cgImage: cgImage)
    }
}
