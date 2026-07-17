//
//  TransactionDetailView.swift
//  MeowHarvest
//
//  Created by JIHANYU MIAO on 7/14/26.
//

import Foundation
import SwiftUI
import UIKit

struct TransactionDetailView: View {
    let transaction: TransactionRecord

    var body: some View {
        List {
            Section("账目信息") {
                LabeledContent(
                    "类型",
                    value: transaction.type.displayName
                )

                LabeledContent(
                    "金额",
                    value: transaction.amount.formatted(
                        .currency(code: "USD")
                    )
                )

                LabeledContent(
                    "分类",
                    value: CategoryCatalog.localizedName(
                        for: transaction.category,
                        type: transaction.type
                    )
                )
                LabeledContent(
                    transaction.type == .expense
                        ? "商家 / 收款人"
                        : "收入来源",
                    value: transaction.vendorOrSource
                )

                LabeledContent(
                    "日期",
                    value: transaction.transactionDate.formatted(
                        date: .long,
                        time: .omitted
                    )
                )

                if !transaction.memo.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("备注")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(transaction.memo)
                    }
                }
            }

            Section("发票与收据") {
                if transaction.receiptImages.isEmpty {
                    ContentUnavailableView(
                        "没有附件",
                        systemImage: "photo",
                        description: Text("这笔账目没有上传发票图片。")
                    )
                } else {
                    ForEach(transaction.receiptImages) { receipt in
                        if let image = UIImage(
                            data: receipt.imageData
                        ) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 12
                                    )
                                )
                                .padding(.vertical, 4)
                        } else {
                            Label(
                                "图片无法读取",
                                systemImage: "exclamationmark.triangle"
                            )
                            .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        .navigationTitle("账目详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(
                placement: .primaryAction
            ) {
                NavigationLink {
                    EditTransactionView(
                        transaction: transaction
                    )
                } label: {
                    Text("transaction_detail.edit")
                }
            }
        }
    }
}
