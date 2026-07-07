import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAdd = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: SessionEntry?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.entries) { entry in
                    Button {
                        editingEntry = entry
                    } label: {
                        row(entry)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("entryRow_\(entry.id)")
                }
                .onDelete { offsets in
                    store.delete(at: offsets)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppTheme.backdrop)
            .navigationTitle("Tennislog")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAdd = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAdd) {
                EntrySheet(entry: nil)
            }
            .sheet(item: $editingEntry) { entry in
                EntrySheet(entry: entry)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    @ViewBuilder
    private func row(_ entry: SessionEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.drillmatch)
                    .font(AppTheme.headlineFont)
                    .foregroundStyle(AppTheme.ink)
                Text("Sets Won: \(entry.value1)  \u{00B7}  Sets Lost: \(entry.value2)")
                    .font(.caption)
                    .foregroundStyle(AppTheme.inkFaded)
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(AppTheme.inkFaded)
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.footnote)
                        .foregroundStyle(AppTheme.inkFaded)
                        .lineLimit(2)
                }
            }
            Spacer()
            Text("\(entry.value1)")
                .font(AppTheme.headlineFont)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppTheme.accent)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

struct EntrySheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    let entry: SessionEntry?

    @State private var option: String = TennislogOptions.all.first ?? ""
    @State private var value1: Double = 5
    @State private var value2: Double = 5
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Drill/Match") {
                    Picker("Drill/Match", selection: $option) {
                        ForEach(TennislogOptions.all, id: \.self) { t in
                            Text(t).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("entryOptionPicker")
                }
                Section("Sets Won: \(Int(value1))") {
                    Slider(value: $value1, in: 0...100, step: 1)
                        .accessibilityIdentifier("entryValue1Slider")
                }
                Section("Sets Lost: \(Int(value2))") {
                    Slider(value: $value2, in: 0...100, step: 1)
                        .accessibilityIdentifier("entryValue2Slider")
                }
                Section("Note") {
                    TextField("Optional note", text: $note, axis: .vertical)
                        .accessibilityIdentifier("entryNoteField")
                }
                if entry != nil {
                    Section {
                        Button("Delete", role: .destructive) {
                            if let entry { store.delete(entry) }
                            dismiss()
                        }
                        .accessibilityIdentifier("entryDeleteButton")
                    }
                }
            }
            .dismissKeyboardOnTap()
            .navigationTitle(entry == nil ? "New Session" : "Edit Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("entryCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if var existing = entry {
                            existing.drillmatch = option
                            existing.value1 = Int(value1)
                            existing.value2 = Int(value2)
                            existing.note = note
                            store.update(existing)
                        } else {
                            store.add(drillmatch: option, value1: Int(value1), value2: Int(value2), note: note)
                        }
                        dismiss()
                    }
                    .accessibilityIdentifier("entrySaveButton")
                }
            }
            .onAppear {
                if let entry {
                    option = entry.drillmatch
                    value1 = Double(entry.value1)
                    value2 = Double(entry.value2)
                    note = entry.note
                }
            }
        }
    }
}
