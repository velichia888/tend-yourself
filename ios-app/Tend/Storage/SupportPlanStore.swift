import Foundation

/// Persists the single SupportPlan struct as JSON in Documents — same
/// file-storage mechanism as the log-style stores, just one document
/// instead of an array.
@MainActor
final class SupportPlanStore: ObservableObject {
    @Published private(set) var plan: SupportPlan = SupportPlan()

    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            self.fileURL = documents.appendingPathComponent("tend_support_plan.json")
        }
        load()
    }

    func addContact(_ contact: SupportContact) {
        plan.contacts.append(contact)
        save()
    }

    func removeContact(_ contact: SupportContact) {
        plan.contacts.removeAll { $0.id == contact.id }
        save()
    }

    func toggleTechnique(_ techniqueID: String) {
        if let index = plan.savedTechniqueIDs.firstIndex(of: techniqueID) {
            plan.savedTechniqueIDs.remove(at: index)
        } else {
            plan.savedTechniqueIDs.append(techniqueID)
        }
        save()
    }

    func addSafePlace(_ place: String) {
        plan.safePlaces.append(place)
        save()
    }

    func resetAllData() {
        plan = SupportPlan()
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode(SupportPlan.self, from: data) {
            plan = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(plan) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
