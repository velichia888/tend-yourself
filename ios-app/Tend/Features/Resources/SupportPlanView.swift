import SwiftUI

struct SupportPlanView: View {
    @EnvironmentObject private var store: SupportPlanStore
    @State private var showingAddContact = false
    @State private var newSafePlace = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                Text("My Support Plan")
                    .font(Theme.Font.display(26))
                    .foregroundStyle(Theme.ink)

                savedTechniquesSection
                safePlacesSection
                contactsSection
            }
            .padding(Theme.Spacing.md)
        }
        .background(Theme.canvas.ignoresSafeArea())
        .navigationTitle("Support Plan")
        #if os(iOS)
	.navigationBarTitleDisplayMode(.inline)
	#endif
        .sheet(isPresented: $showingAddContact) {
            AddSupportContactView().environmentObject(store)
        }
    }

    private var savedTechniquesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Saved techniques").font(Theme.Font.headline(16)).foregroundStyle(Theme.ink)
            let saved = ResourceCatalog.categories.filter { store.plan.savedTechniqueIDs.contains($0.id) }
            if saved.isEmpty {
                Text("Save a technique from Resources to see it here.")
                    .font(Theme.Font.body(13)).foregroundStyle(Theme.inkSoft)
            } else {
                ForEach(saved) { category in
                    IconBadgeCard(category: category.category, icon: category.icon, title: category.title, subtitle: category.subtitle)
                }
            }
        }
    }

    private var safePlacesSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Safe places").font(Theme.Font.headline(16)).foregroundStyle(Theme.ink)
            ForEach(store.plan.safePlaces, id: \.self) { place in
                Text("• \(place)").font(Theme.Font.body(14)).foregroundStyle(Theme.ink)
            }
            HStack {
                TextField("Add a safe place", text: $newSafePlace)
                    .textFieldStyle(.roundedBorder)
                Button("Add") {
                    guard !newSafePlace.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    store.addSafePlace(newSafePlace)
                    newSafePlace = ""
                }
            }
        }
    }

    private var contactsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text("Trusted contacts").font(Theme.Font.headline(16)).foregroundStyle(Theme.ink)
                Spacer()
                Button("Edit") { showingAddContact = true }
                    .font(Theme.Font.body(13))
            }
            if store.plan.contacts.isEmpty {
                Text("No contacts saved yet.")
                    .font(Theme.Font.body(13)).foregroundStyle(Theme.inkSoft)
            } else {
                ForEach(store.plan.contacts) { contact in
                    IconBadgeCard(category: .selfCare, icon: "person.fill", title: contact.name, subtitle: contact.relationship)
                }
            }
        }
    }
}

private struct AddSupportContactView: View {
    @EnvironmentObject private var store: SupportPlanStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var relationship = ""
    @State private var phoneNumber = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Relationship (e.g. Mom, Friend, Therapist)", text: $relationship)
                TextField("Phone number", text: $phoneNumber)
                    #if os(iOS)
		.keyboardType(.phonePad)
		#endif

                if !store.plan.contacts.isEmpty {
                    Section("Existing contacts") {
                        ForEach(store.plan.contacts) { contact in
                            Text("\(contact.name) — \(contact.relationship)")
                        }
                        .onDelete { indices in
                            for index in indices { store.removeContact(store.plan.contacts[index]) }
                        }
                    }
                }
            }
            .navigationTitle("Support Contacts")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        store.addContact(SupportContact(name: name, relationship: relationship, phoneNumber: phoneNumber))
                        name = ""; relationship = ""; phoneNumber = ""
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || phoneNumber.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SupportPlanView().environmentObject(SupportPlanStore())
    }
}
