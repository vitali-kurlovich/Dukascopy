import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(TicksCollectionTest.allTests),
            testCase(DukascopyCandlesCollectionTest.allTests),

            testCase(DukascopyTicksProviderTests.allTests),
            testCase(DukascopyCandlesProviderTests.allTests),
        ]
    }
#endif
