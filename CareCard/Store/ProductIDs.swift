import Foundation

/// ProductID厳守（コードとASC完全一致必須）。買い切りのみ（月額プランは作らない）。
enum ProductIDs {
    static let unlock = "com.goonobu.caremanecard.unlock"
    static let all = [unlock]
}
