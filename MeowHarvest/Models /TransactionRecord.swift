//
//  TransactionRecord.swift
//  MeowHarvest
//
//  Created by JIHANYU MIAO on 7/14/26.
//

import Foundation
import SwiftData

@Model
final class TransactionRecord {
    var id: UUID
    var typeRawValue: String
    var transactionDate: Date
    var amount: Double
    var category: String
    var vendorOrSource: String
    var memo: String
    var createdAt: Date

    @Relationship(
        deleteRule: .cascade,
        inverse: \ReceiptImage.transaction
    )
    var receiptImages: [ReceiptImage]

    var type: TransactionType {
        get {
            TransactionType.fromStoredValue(typeRawValue)
        }
        set {
            typeRawValue = newValue.rawValue
        }
    }

    init(
        type: TransactionType,
        transactionDate: Date,
        amount: Double,
        category: String,
        vendorOrSource: String,
        memo: String = "",
        receiptImages: [ReceiptImage] = []
    ) {
        self.id = UUID()
        self.typeRawValue = type.rawValue
        self.transactionDate = transactionDate
        self.amount = amount
        self.category = category
        self.vendorOrSource = vendorOrSource
        self.memo = memo
        self.createdAt = Date()
        self.receiptImages = receiptImages
    }
}
