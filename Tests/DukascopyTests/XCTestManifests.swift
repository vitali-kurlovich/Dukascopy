import XCTest

#if !canImport(ObjectiveC)
    public func allTests() -> [XCTestCaseEntry] {
        [
            testCase(DukascopyTests.allTests),
            testCase(DukascopyURLFactoryTests.allTests),
            testCase(TicksCollectionTest.allTests),
        ]
    }
#endif
