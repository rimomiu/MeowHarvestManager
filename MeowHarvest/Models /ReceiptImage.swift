//
//  ReceiptImage.swift
//  MeowHarvest
//
//  Created by JIHANYU MIAO on 7/14/26.
//

import Foundation
import SwiftData

@Model
final class ReceiptImage {
    var id: UUID

    @Attribute(.externalStorage)
    var imageData: Data

    var createdAt: Date
    var transaction: TransactionRecord?

    init(imageData: Data) {
        self.id = UUID()
        self.imageData = imageData
        self.createdAt = Date()
    }
}
