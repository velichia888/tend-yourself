import Foundation

struct SupportContact: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var relationship: String
    var phoneNumber: String

    init(id: UUID = UUID(), name: String, relationship: String, phoneNumber: String) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.phoneNumber = phoneNumber
    }
}
