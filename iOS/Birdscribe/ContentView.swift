import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false
    @State private var editingEntry: SightingEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        Button {
                            editingEntry = entry
                        } label: {
                            EntryRow(entry: entry)
                        }
                        .accessibilityIdentifier("entry_row_\(entry.name)")
                        .listRowBackground(Theme.cardBackground)
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Birdscribe")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settings_button")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("add_button")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddEntrySheet(isPresented: $showingAdd)
                    .environmentObject(store)
            }
            .sheet(item: $editingEntry) { entry in
                EditEntrySheet(entry: entry)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView(isPresented: $showingPaywall)
                    .environmentObject(purchases)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(isPresented: $showingSettings)
                    .environmentObject(purchases)
            }
        }
        .tint(Theme.accent)
    }
}

struct EntryRow: View {
    let entry: SightingEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.name)
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text(entry.species)
                .font(Theme.bodyFont)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.vertical, 4)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.bodyFont)
        }
    }
}

struct AddEntrySheet: View {
    @EnvironmentObject var store: Store
    @Binding var isPresented: Bool
    @State private var draftName: String = ""
    @State private var draftSpecies: String = ""
    @State private var draftLocation: String = ""
    @State private var draftHabitat: String = ""
    @State private var draftNotes: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Sighting Details") {
                    TextField("Name", text: $draftName)
                        .accessibilityIdentifier("field_name")
                    TextField("Species", text: $draftSpecies)
                .accessibilityIdentifier("field_species")
            TextField("Location", text: $draftLocation)
                .accessibilityIdentifier("field_location")
            TextField("Habitat", text: $draftHabitat)
                .accessibilityIdentifier("field_habitat")
            TextField("Notes", text: $draftNotes)
                .accessibilityIdentifier("field_notes")
                }
            }
            .navigationTitle("New Sighting")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                        .accessibilityIdentifier("cancel_add_button")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(name: draftName, species: draftSpecies, location: draftLocation, habitat: draftHabitat, notes: draftNotes)
                        isPresented = false
                    }
                    .accessibilityIdentifier("save_add_button")
                    .disabled(draftName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

struct EditEntrySheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @State var entry: SightingEntry

    var body: some View {
        NavigationStack {
            Form {
                Section("Sighting Details") {
                    TextField("Name", text: $entry.name)
                        .accessibilityIdentifier("edit_field_name")
                    TextField("Species", text: $entry.species)
                    TextField("Location", text: $entry.location)
                    TextField("Habitat", text: $entry.habitat)
                    TextField("Notes", text: $entry.notes)
                }
                Section {
                    Button(role: .destructive) {
                        store.delete(entry)
                        dismiss()
                    } label: {
                        Text("Delete")
                    }
                    .accessibilityIdentifier("delete_entry_button")
                }
            }
            .navigationTitle("Edit Sighting")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        store.update(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("save_edit_button")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
