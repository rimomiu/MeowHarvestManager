import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var transactionType: TransactionType = .expense
    @State private var transactionDate = Date()
    @State private var amountText = ""
    @State private var category = CategoryCatalog.expenseCategories[0]
    @State private var vendorOrSource = ""
    @State private var memo = ""
    @State private var showSavedAlert = false

    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var receiptImageData: [Data] = []
    @State private var isShowingCamera = false

    private var categories: [String] {
        transactionType == .expense
            ? CategoryCatalog.expenseCategories
            : CategoryCatalog.incomeCategories
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("账目信息") {
                    Picker("类型", selection: $transactionType) {
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
                        "日期",
                        selection: $transactionDate,
                        displayedComponents: .date
                    )

                    TextField("金额", text: $amountText)
                        .keyboardType(.decimalPad)

                    Picker("分类", selection: $category) {
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

                    TextField(
                        transactionType == .expense
                            ? "商家 / 收款人"
                            : "收入来源",
                        text: $vendorOrSource
                    )

                    TextField(
                        "备注",
                        text: $memo,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }

                Section("发票与收据") {
                    PhotosPicker(
                        selection: $selectedPhotoItems,
                        maxSelectionCount: 20,
                        matching: .images
                    ) {
                        Label(
                            "从相册选择多张图片",
                            systemImage: "photo.on.rectangle.angled"
                        )
                    }
                    .onChange(of: selectedPhotoItems) {
                        Task {
                            await loadSelectedPhotos()
                        }
                    }

                    Button {
                        isShowingCamera = true
                    } label: {
                        Label(
                            "拍照",
                            systemImage: "camera"
                        )
                    }

                    if !receiptImageData.isEmpty {
                        ScrollView(
                            .horizontal,
                            showsIndicators: false
                        ) {
                            HStack(spacing: 12) {
                                ForEach(
                                    Array(receiptImageData.enumerated()),
                                    id: \.offset
                                ) { index, data in
                                    if let image = UIImage(data: data) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(
                                                    width: 110,
                                                    height: 110
                                                )
                                                .clipShape(
                                                    RoundedRectangle(
                                                        cornerRadius: 12
                                                    )
                                                )
                                                .clipped()

                                            Button {
                                                receiptImageData.remove(
                                                    at: index
                                                )
                                            } label: {
                                                Image(
                                                    systemName:
                                                        "xmark.circle.fill"
                                                )
                                                .font(.title2)
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(
                                                    .white,
                                                    .black.opacity(0.7)
                                                )
                                            }
                                            .padding(5)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        Text(
                            "已选择 \(receiptImageData.count) 张图片"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button("保存记录") {
                        saveTransaction()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!formIsValid)
                }
            }
            .navigationTitle("新增账目")
            .alert(
                "保存成功",
                isPresented: $showSavedAlert
            ) {
                Button("好的", role: .cancel) {}
            }
            .sheet(
                isPresented: $isShowingCamera
            ) {
                CameraPickerView { imageData in
                    if let imageData {
                        receiptImageData.append(imageData)
                    }
                }
            }
        }
    }

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

    private func saveTransaction() {
        guard let amount = Double(amountText),
              amount > 0 else {
            return
        }

        let receiptImages = receiptImageData.map {
            ReceiptImage(imageData: $0)
        }

        let transaction = TransactionRecord(
            type: transactionType,
            transactionDate: transactionDate,
            amount: amount,
            category: category,
            vendorOrSource: vendorOrSource
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
            memo: memo
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
            receiptImages: receiptImages
        )

        modelContext.insert(transaction)

        do {
            try modelContext.save()
            resetForm()
            showSavedAlert = true
        } catch {
            print(
                "Save failed: \(error.localizedDescription)"
            )
        }
    }

    private func resetForm() {
        transactionDate = Date()
        amountText = ""
        vendorOrSource = ""
        memo = ""
        category = categories[0]
        selectedPhotoItems = []
        receiptImageData = []
    }

    @MainActor
    private func loadSelectedPhotos() async {
        for item in selectedPhotoItems {
            do {
                if let data = try await item.loadTransferable(
                    type: Data.self
                ) {
                    receiptImageData.append(data)
                }
            } catch {
                print(
                    "读取图片失败：\(error.localizedDescription)"
                )
            }
        }

        selectedPhotoItems = []
    }
}
