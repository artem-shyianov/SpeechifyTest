import Foundation

struct PaymentType: Identifiable, Hashable {
    var id = UUID().uuidString
    var name: String
}

enum PaymentError: Error {
    case timeout
}

protocol PaymentTypesRepository {
    func getTypes(completion: @escaping (Swift.Result<[PaymentType], PaymentError>) -> Void)
}

class PaymentTypesRepositoryImplementation: PaymentTypesRepository {
    private lazy var types: [PaymentType] = {
        [
            PaymentType(name: "Apple Pay"),
            PaymentType(name: "Visa"),
            PaymentType(name: "Mastercard"),
            PaymentType(name: "Maestro"),
            PaymentType(name: "Google pay")
        ]
    }()

    func getTypes(completion: @escaping (Swift.Result<[PaymentType], PaymentError>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(.success(self.types.shuffled()))
        }
    }
}
