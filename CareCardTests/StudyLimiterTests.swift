import XCTest
@testable import CareCard

final class StudyLimiterTests: XCTestCase {

    func testFreeTopicIsShienFirstTopicOnly() {
        XCTAssertTrue(StudyLimiter.isCardFree(subject: .shien, topic: "介護保険制度のしくみ"))
        XCTAssertFalse(StudyLimiter.isCardFree(subject: .shien, topic: "要介護認定"))
        XCTAssertFalse(StudyLimiter.isCardFree(subject: .hoken, topic: "介護保険制度のしくみ"))
    }

    func testDailyLimitBoundary() {
        XCTAssertEqual(StudyLimiter.remainingFreeCardsToday(alreadyStudiedToday: 0), 20)
        XCTAssertEqual(StudyLimiter.remainingFreeCardsToday(alreadyStudiedToday: 19), 1)
        XCTAssertEqual(StudyLimiter.remainingFreeCardsToday(alreadyStudiedToday: 20), 0)
        XCTAssertEqual(StudyLimiter.remainingFreeCardsToday(alreadyStudiedToday: 999), 0, "上限を超えても負数にならない")
    }

    func testCanStudyProAlwaysAllowed() {
        XCTAssertTrue(StudyLimiter.canStudy(subject: .hoken, topic: "何でも", alreadyStudiedToday: 999, isPro: true))
    }

    func testCanStudyFreeUserWithinLimit() {
        XCTAssertTrue(StudyLimiter.canStudy(subject: .shien, topic: "介護保険制度のしくみ", alreadyStudiedToday: 5, isPro: false))
    }

    func testCanStudyFreeUserAtLimitBlocked() {
        XCTAssertFalse(StudyLimiter.canStudy(subject: .shien, topic: "介護保険制度のしくみ", alreadyStudiedToday: 20, isPro: false))
    }

    func testCanStudyFreeUserOutsideFreeTopicBlocked() {
        XCTAssertFalse(StudyLimiter.canStudy(subject: .fukushi, topic: "成年後見", alreadyStudiedToday: 0, isPro: false))
    }
}
