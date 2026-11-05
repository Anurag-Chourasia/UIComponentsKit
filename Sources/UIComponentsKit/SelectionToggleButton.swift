import SwiftUI

/// A controlled selection action. Hosts retain persistence, styling and feedback ownership.
public struct SelectionToggleButton<Label: View>: View {
    private let isSelected: Bool
    private let selectedLabel: String
    private let unselectedLabel: String
    private let action: () -> Void
    private let label: Label

    public init(isSelected: Bool, selectedLabel: String, unselectedLabel: String,
                action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.isSelected = isSelected
        self.selectedLabel = selectedLabel
        self.unselectedLabel = unselectedLabel
        self.action = action
        self.label = label()
    }

    public var body: some View {
        Button(action: action) { label }
            .buttonStyle(.plain)
            .accessibilityLabel(isSelected ? selectedLabel : unselectedLabel)
    }
}
