//
//  FileAssistants.swift
//  Pixel Nodes
//
//  Created by Hexagons on 2017-11-24.
//  Copyright © 2017 Hexagons. All rights reserved.
//

import UIKit
import SpriteKit
import Photos
import MobileCoreServices

enum MediaType {
    case photo
    case image
    case camera_image
    case video
    case camera_video
    case audio
    case vector
    case gif
}

class FileAssistant {
    
    static let shared = FileAssistant()
    
    let media_picker_assistant: MediaPickerAssistant
    let document_picker_assistant: DocumentPickerAssistant
    let image_url_assistant: ImageURLAssistant

    init() {
        
        self.media_picker_assistant = MediaPickerAssistant()
        self.document_picker_assistant = DocumentPickerAssistant()
        self.image_url_assistant = ImageURLAssistant()
        
    }
    
}

class MediaPickerAssistant: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var media_type: MediaType?
    var media_picker: UIImagePickerController
    var pickedImage: ((UIImage) -> ())?
    var pickedGIF: ((URL) -> ())?
    var pickedVideo: ((URL) -> ())?
    
    override init() {
        
        self.media_picker = UIImagePickerController()
        
        super.init()
        
        self.media_picker.delegate = self
        
    }
    
    func pickMedia(media_type: MediaType, pickedImage: ((UIImage) -> ())? = nil, pickedGIF: ((URL) -> ())? = nil, pickedVideo: ((URL) -> ())? = nil) {
        
        self.media_type = media_type
        self.pickedImage = pickedImage
        self.pickedGIF = pickedGIF
        self.pickedVideo = pickedVideo
        
        switch media_type {
        case .photo, .image, .camera_image:
            self.media_picker.mediaTypes = [kUTTypeImage, kUTTypeLivePhoto] as [String]
        case .video, .camera_video:
            self.media_picker.mediaTypes = [kUTTypeMovie] as [String]
        case .gif:
            self.media_picker.mediaTypes = [kUTTypeGIF] as [String]
        default: break
        }
        
        switch media_type {
        case .camera_image, .camera_video:
            self.media_picker.sourceType = .camera
        case .photo:
            self.media_picker.sourceType = .photoLibrary
        case .gif:
            // FIXME: - GIF Crash
            break
        default:
            self.media_picker.sourceType = .savedPhotosAlbum
        }
        
        // self.media_picker.isSourceTypeAvailable(...)
        
        if !self.media_picker.isBeingPresented {
            ViewAssistant.shared.vc!.present(self.media_picker, animated: true, completion: nil)
        }
    }
    
    func saveVideo(url: URL, alert_sheet_view: UIView? = nil) {
        self.checkPermission { access in
            if access {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { saved, error in
                    if saved {
                        var alert_actions: [ViewAssistant.AlertAction] = []
                        alert_actions.append(ViewAssistant.AlertAction(title: "Open Photos App", style: .default, handeler: { _ in
                            UIApplication.shared.open(URL(string: "photos-redirect://")!, options: [:], completionHandler: nil)
                        }))
                        ViewAssistant.shared.alert("Video Saved", actions: alert_actions, sheet_view: alert_sheet_view)
                    } else {
                        ViewAssistant.shared.alert("Error Saving Video", sheet_view: alert_sheet_view)
                        print("File Error:", "Saving video.", error)
                    }
                }
            } else {
                ViewAssistant.shared.alert("Video not saved", "Permission denied.", sheet_view: alert_sheet_view)
                print("File Error:", "Video not saved. Permission denied.")
            }
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.media_picker.dismiss(animated: true, completion: nil)
        switch self.media_type! {
        case .gif:
            let img_url = info[.imageURL] as! URL
//            self.checkPermission(access: { granted in
//                if granted {
                    DispatchQueue.main.async {
                        self.pickedGIF!(img_url)
                    }
//                }
//            })
        case .photo, .image:
            if false /*self.isGIF(info: info)*/ {
            } else {
                // UIImagePickerControllerEditedImage
                let img = info[.originalImage] as! UIImage
                DispatchQueue.main.async {
                    self.pickedImage!(img)
                }
            }
//            switch info["UIImagePickerControllerMediaType"] as! String {
//            case "com.apple.live-photo":
//                let live_photo = info["UIImagePickerControllerLivePhoto"] as! PHLivePhoto
//                self.pickedImage!(img, live_photo)
//            case "public.image":
//                self.pickedImage!(img, nil)
//            default: break
//            }
        case .camera_image:
            let img = info[.originalImage] as! UIImage
            self.pickedImage!(img)
        case .video, .camera_video:
            let url = info[.mediaURL] as! URL
            self.pickedVideo!(url)
        default: break
        }
    }
    
//    func isGIF(info: [String : Any]) -> Bool {
//        let info_components = (info["UIImagePickerControllerReferenceURL"] as! URL).absoluteString.components(separatedBy: "&")
//        for info_component in info_components {
//            let components = info_component.components(separatedBy: "=")
//            if components.first! == "ext" {
//                if components.count == 2 {
//                    if components.last! == "GIF" {
//                        return true
//                    }
//                }
//            }
//        }
//        return false
//    }
    
    func checkPermission(access: @escaping (Bool) -> ()) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            access(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        access(true)
                    } else {
                        access(false)
                    }
                }
            })
        case .restricted:
            access(false)
        case .denied:
            access(false)
        }
    }
    
}

class DocumentPickerAssistant: NSObject, UIDocumentPickerDelegate {
    
    var document_picker_view_controller: UIDocumentPickerViewController?
    var pickedDocument: ((URL, Bool) -> ())?
    
    override init() {
        
        super.init()
        
    }
    
    func pickDocument(media_type: MediaType, pickedDocument: @escaping (URL, Bool) -> ()) {
        
        var document_types: [String] = []
        switch media_type {
        case .gif:
            document_types = [String(kUTTypeGIF)]
        case .image:
            document_types = [String(kUTTypeImage)]
        case .video:
            document_types = [String(kUTTypeMovie), String(kUTTypeVideo)]
        case .audio:
            document_types = [String(kUTTypeMP3), String(kUTTypeAudio)]
        case .vector:
            document_types = [String(kUTTypeScalableVectorGraphics)]
        default: break
        }
        self.document_picker_view_controller = UIDocumentPickerViewController(documentTypes: document_types, in: .import)
        self.document_picker_view_controller?.delegate = self
        
        self.pickedDocument = pickedDocument
        
        if !self.document_picker_view_controller!.isBeingPresented {
            ViewAssistant.shared.vc!.present(self.document_picker_view_controller!, animated: true, completion: nil)
        }
        
    }
    
    func saveURL(_ url: URL) {
        self.document_picker_view_controller = UIDocumentPickerViewController(url: url, in: .exportToService)
        if !self.document_picker_view_controller!.isBeingPresented {
            ViewAssistant.shared.vc!.present(self.document_picker_view_controller!, animated: true, completion: nil)
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let is_gif = self.isGIF(url: url)
        DispatchQueue.main.async {
            self.pickedDocument!(url, is_gif)
        }
    }
    
    func isGIF(url: URL) -> Bool {
        let ext = url.absoluteString.components(separatedBy: ".").last!
        if ext == "gif" || ext == "GIF" {
            return true
        }
        return false
    }
    
}

class ImageURLAssistant {
    
    init() {
        
    }
    
    func loadURL(_ url: URL?, loadedImage: @escaping (UIImage) -> (), loadedGIF: @escaping (Data) ->(), alert_sheet_view: UIView?) {
        
        if url != nil {
            
            URLSession.shared.dataTask(with: url!, completionHandler: { data, response, error in
                if error == nil {
                    
                    if data != nil {
                        
                        if self.isGIF(url: url!) {
                            
                            DispatchQueue.main.async {
                                loadedGIF(data!)
                            }
                            
                        } else {

                            let image = UIImage(data: data!)
                            
                            if image != nil {
                                
                                DispatchQueue.main.async {
                                    loadedImage(image!)
                                }
                                
                            } else {
                                
                                ViewAssistant.shared.alert("Error loading image", sheet_view: alert_sheet_view)
                                print("File Error:", "Error loading image.")
                                
                            }
                            
                        }
                        
                    } else {
                        
                        ViewAssistant.shared.alert("Error loading data", sheet_view: alert_sheet_view)
                        print("File Error:", "Error loading data.")
                        
                    }
                    
                } else {
                    
                    ViewAssistant.shared.alert("Error loading URL", sheet_view: alert_sheet_view)
                    print("File Error:", "Error loading url.")
                    
                }
            }).resume()
            
        } else {
            
            ViewAssistant.shared.alert("Invliad URL", sheet_view: alert_sheet_view)
            print("File Error:", "Invliad url.")
            
        }
        
    }
    
    func isGIF(url: URL) -> Bool {
        let ext = url.absoluteString.components(separatedBy: ".").last!
        if ext == "gif" || ext == "GIF" {
            return true
        }
        return false
    }
    
}
