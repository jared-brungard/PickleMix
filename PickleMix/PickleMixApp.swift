
import SwiftUI
// Loads the Format SelectionView as the initial view when the app is loaded
@main
struct PickleMixApp: App {
    @State private var store = GroupsStore()

    var body: some Scene {
        WindowGroup {
            FormatSelectionView()
                .environment(store)
        }
    }
}
