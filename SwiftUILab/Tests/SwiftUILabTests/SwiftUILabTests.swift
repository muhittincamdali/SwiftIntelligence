import XCTest
@testable import SwiftUILab
@testable import SwiftUILabButtons

final class SwiftUILabTests: XCTestCase {
    
    func testSwiftUILabVersion() {
        XCTAssertEqual(SwiftUILab.version, "1.0.0")
    }
    
    func testComponentCount() {
        XCTAssertEqual(SwiftUILab.componentCount, 120)
    }
    
    func testCategoryCount() {
        XCTAssertEqual(SwiftUILab.Category.allCases.count, 12)
    }
    
    func testButtonComponents() {
        XCTAssertEqual(SwiftUILabButtons.Component.allCases.count, 10)
    }
    
    func testThemeDefaults() {
        let theme = SwiftUILab.Theme.default
        XCTAssertEqual(theme.cornerRadius, 12)
        XCTAssertEqual(theme.spacing, 16)
        XCTAssertEqual(theme.animationDuration, 0.3)
    }
}