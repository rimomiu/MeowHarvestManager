//
//  CameraPickerView.swift
//  MeowHarvest
//
//  Created by JIHANYU MIAO on 7/14/26.
//

import Foundation
import SwiftUI
import UIKit

struct CameraPickerView: UIViewControllerRepresentable {
    let onImageCaptured: (Data?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured)
    }

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {
        let picker = UIImagePickerController()

        // 真机使用相机；Simulator 没有相机时退回相册
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }

        picker.delegate = context.coordinator
        picker.allowsEditing = false

        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
        // 不需要实时更新
    }

    final class Coordinator:
        NSObject,
        UINavigationControllerDelegate,
        UIImagePickerControllerDelegate
    {
        let onImageCaptured: (Data?) -> Void

        init(
            onImageCaptured: @escaping (Data?) -> Void
        ) {
            self.onImageCaptured = onImageCaptured
        }

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            onImageCaptured(nil)
            picker.dismiss(animated: true)
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [
                UIImagePickerController.InfoKey: Any
            ]
        ) {
            let image = info[.originalImage] as? UIImage

            let imageData = image?.jpegData(
                compressionQuality: 0.82
            )

            onImageCaptured(imageData)
            picker.dismiss(animated: true)
        }
    }
}
