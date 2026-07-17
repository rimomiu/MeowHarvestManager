import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct EditTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let transaction: TransactionRecord

    @State private var transactionType: TransactionType
    @State private var transactionDate: Date
    @State private var amountText: String
    @State private var category: String
    @State private var vendorOrSource: String
    @State private var memo: String

    @State private var showSaveError = false
    @State private var saveErrorMessage = ""

    // 新增图片时使用
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var newReceiptImageData: [Data] = []
    @State private var isShowingCamera = false

    // 暂时标记准备删除的旧收据
    @State private var receiptIDsMarkedForDeletion: Set<UUID> = []

    private var categories: [String] {
        CategoryCatalog.categories(
            for: transactionType
        )
    }

    init(transaction: TransactionRecord) {
        self.transaction = transaction

        _transactionType = State(
            initialValue: transaction.type
        )

        _transactionDate = State(
            initialValue: transaction.transactionDate
        )

        _amountText = State(
            initialValue: String(transaction.amount)
        )

        _category = State(
            initialValue: CategoryCatalog.normalizedID(
                from: transaction.category,
                type: transaction.type
            )
        )

        _vendorOrSource = State(
            initialValue: transaction.vendorOrSource
        )

        _memo = State(
            initialValue: transaction.memo
        )
    }

    var body: some View {
        Form {
            // MARK: - 账目信息

            Section(
                "edit_transaction.section_information"
            ) {
                Picker(
                    "edit_transaction.type",
                    selection: $transactionType
                ) {
                    ForEach(TransactionType.allCases) { type in
                        Text(type.displayName)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: transactionType) {
                    category = categories[0]
                }

                DatePicker(
                    "edit_transaction.date",
                    selection: $transactionDate,
                    displayedComponents: .date
                )

                TextField(
                    "edit_transaction.amount",
                    text: $amountText
                )
                .keyboardType(.decimalPad)

                Picker(
                    "edit_transaction.category",
                    selection: $category
                ) {
                    ForEach(categories, id: \.self) { item in
                        Text(
                            CategoryCatalog.localizedName(
                                for: item,
                                type: transactionType
                            )
                        )
                        .tag(item)
                    }
                }

                if transactionType == .expense {
                    TextField(
                        "edit_transaction.vendor_expense",
                        text: $vendorOrSource
                    )
                } else {
                    TextField(
                        "edit_transaction.vendor_income",
                        text: $vendorOrSource
                    )
                }

                TextField(
                    "edit_transaction.memo",
                    text: $memo,
                    axis: .vertical
                )
                .lineLimit(3...6)
            }

            // MARK: - 原有收据图片

            Section(
                "edit_transaction.receipts_section"
            ) {
                if transaction.receiptImages.isEmpty {
                    ContentUnavailableView(
                        "edit_transaction.no_receipts",
                        systemImage: "photo",
                        description: Text(
                            "edit_transaction.no_receipts_description"
                        )
                    )
                } else {
                    ForEach(
                        transaction.receiptImages
                    ) { receipt in
                        if let image = UIImage(
                            data: receipt.imageData
                        ) {
                            VStack(spacing: 10) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 260)
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 12
                                        )
                                    )
                                    .opacity(
                                        receiptIDsMarkedForDeletion
                                            .contains(receipt.id)
                                            ? 0.35
                                            : 1
                                    )

                                Button {
                                    toggleReceiptDeletion(
                                        receiptID: receipt.id
                                    )
                                } label: {
                                    if receiptIDsMarkedForDeletion
                                        .contains(receipt.id) {
                                        Label(
                                            "edit_transaction.restore_receipt",
                                            systemImage:
                                                "arrow.uturn.backward"
                                        )
                                    } else {
                                        Label(
                                            "edit_transaction.remove_receipt",
                                            systemImage: "trash"
                                        )
                                    }
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(.vertical, 6)
                        } else {
                            Label(
                                "edit_transaction.image_unavailable",
                                systemImage:
                                    "exclamationmark.triangle"
                            )
                            .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        .navigationTitle(
            Text("edit_transaction.navigation_title")
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(
                placement: .confirmationAction
            ) {
                Button("edit_transaction.save") {
                    saveChanges()
                }
                .disabled(!formIsValid)
            }
        }
        .alert(
            "edit_transaction.save_failed",
            isPresented: $showSaveError
        ) {
            Button(
                "common.ok",
                role: .cancel
            ) {}
        } message: {
            Text(saveErrorMessage)
        }
    }

    // MARK: - 表格验证

    private var formIsValid: Bool {
        guard let amount = Double(amountText),
              amount > 0 else {
            return false
        }

        return !vendorOrSource
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
    }

    // MARK: - 标记或恢复收据

    private func toggleReceiptDeletion(
        receiptID: UUID
    ) {
        if receiptIDsMarkedForDeletion.contains(
            receiptID
        ) {
            receiptIDsMarkedForDeletion.remove(
                receiptID
            )
        } else {
            receiptIDsMarkedForDeletion.insert(
                receiptID
            )
        }
    }

    // MARK: - 保存修改

    private func saveChanges() {
        guard let amount = Double(amountText),
              amount > 0 else {
            return
        }

        transaction.type = transactionType
        transaction.transactionDate = transactionDate
        transaction.amount = amount
        transaction.category = category

        transaction.vendorOrSource = vendorOrSource
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        transaction.memo = memo
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        // 找出用户标记为删除的收据
        let receiptsToDelete = transaction.receiptImages.filter {
            receiptIDsMarkedForDeletion.contains($0.id)
        }

        // 从这笔账目的图片关系中移除
        transaction.receiptImages.removeAll {
            receiptIDsMarkedForDeletion.contains($0.id)
        }

        // 从 SwiftData 中删除图片对象
        for receipt in receiptsToDelete {
            modelContext.delete(receipt)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            saveErrorMessage = error.localizedDescription
            showSaveError = true
        }
    }
}
