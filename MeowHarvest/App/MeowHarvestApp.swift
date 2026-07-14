import SwiftUI
import SwiftData

@main
struct MeowHarvestApp: App {
    private let modelContainer: ModelContainer = {
        let schema = Schema([
            TransactionRecord.self,
            ReceiptImage.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Unable to create model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(modelContainer)
    }
}
