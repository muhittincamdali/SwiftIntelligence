#!/bin/bash

# SwiftIntelligence - Test Coverage Report Generator
# Generates comprehensive test coverage reports with badges

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="SwiftIntelligence"
BUILD_DIR=".build"
COVERAGE_DIR="coverage"
DOCS_DIR="docs/coverage"

# Functions
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        SwiftIntelligence Coverage Report Generator        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}▶ $1${NC}"
}

print_error() {
    echo -e "${RED}✖ Error: $1${NC}"
    exit 1
}

print_success() {
    echo -e "${GREEN}✔ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check dependencies
check_dependencies() {
    print_step "Checking dependencies..."
    
    if ! command -v swift &> /dev/null; then
        print_error "Swift is not installed"
    fi
    
    if ! command -v xcrun &> /dev/null; then
        print_error "Xcode Command Line Tools not installed"
    fi
    
    print_success "All dependencies satisfied"
}

# Clean previous coverage
clean_coverage() {
    print_step "Cleaning previous coverage data..."
    rm -rf "$COVERAGE_DIR"
    rm -rf "$BUILD_DIR/debug/codecov"
    mkdir -p "$COVERAGE_DIR"
    mkdir -p "$DOCS_DIR"
    print_success "Cleaned coverage directories"
}

# Run tests with coverage
run_tests() {
    print_step "Running tests with code coverage..."
    
    swift test --enable-code-coverage --parallel 2>&1 | tee "$COVERAGE_DIR/test-output.log"
    
    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        print_error "Tests failed. Check $COVERAGE_DIR/test-output.log for details"
    fi
    
    print_success "Tests completed successfully"
}

# Generate coverage data
generate_coverage_data() {
    print_step "Generating coverage data..."
    
    # Find the test binary
    TEST_BINARY=$(find "$BUILD_DIR/debug" -name "${PROJECT_NAME}PackageTests.xctest" -type d | head -1)
    
    if [ -z "$TEST_BINARY" ]; then
        print_error "Test binary not found"
    fi
    
    # Platform-specific binary path
    if [[ "$OSTYPE" == "darwin"* ]]; then
        BINARY_PATH="$TEST_BINARY/Contents/MacOS/${PROJECT_NAME}PackageTests"
    else
        BINARY_PATH="$TEST_BINARY/${PROJECT_NAME}PackageTests"
    fi
    
    # Find profdata
    PROFDATA="$BUILD_DIR/debug/codecov/default.profdata"
    
    if [ ! -f "$PROFDATA" ]; then
        print_error "Profile data not found at $PROFDATA"
    fi
    
    print_success "Found test binary and profile data"
}

# Generate LCOV report
generate_lcov() {
    print_step "Generating LCOV coverage report..."
    
    xcrun llvm-cov export \
        "$BINARY_PATH" \
        -instr-profile="$PROFDATA" \
        -format=lcov \
        -ignore-filename-regex="Tests|Examples|DemoApps" \
        > "$COVERAGE_DIR/coverage.lcov"
    
    print_success "Generated coverage.lcov"
}

# Generate JSON report
generate_json() {
    print_step "Generating JSON coverage report..."
    
    xcrun llvm-cov export \
        "$BINARY_PATH" \
        -instr-profile="$PROFDATA" \
        -format=json \
        -ignore-filename-regex="Tests|Examples|DemoApps" \
        > "$COVERAGE_DIR/coverage.json"
    
    print_success "Generated coverage.json"
}

# Generate HTML report
generate_html() {
    print_step "Generating HTML coverage report..."
    
    xcrun llvm-cov show \
        "$BINARY_PATH" \
        -instr-profile="$PROFDATA" \
        -format=html \
        -output-dir="$DOCS_DIR" \
        -ignore-filename-regex="Tests|Examples|DemoApps" \
        -show-line-counts-or-regions \
        -show-instantiations \
        -show-expansions
    
    print_success "Generated HTML report in $DOCS_DIR"
}

# Generate text summary
generate_summary() {
    print_step "Generating coverage summary..."
    
    xcrun llvm-cov report \
        "$BINARY_PATH" \
        -instr-profile="$PROFDATA" \
        -ignore-filename-regex="Tests|Examples|DemoApps" \
        > "$COVERAGE_DIR/coverage-summary.txt"
    
    # Also display in console
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                    Coverage Summary                        ${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    cat "$COVERAGE_DIR/coverage-summary.txt"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    
    print_success "Generated coverage summary"
}

# Extract coverage percentage
extract_coverage_percentage() {
    print_step "Extracting coverage percentage..."
    
    # Get the total coverage from the last line of the report
    COVERAGE_PCT=$(xcrun llvm-cov report \
        "$BINARY_PATH" \
        -instr-profile="$PROFDATA" \
        -ignore-filename-regex="Tests|Examples|DemoApps" \
        | tail -1 \
        | awk '{print $10}' \
        | sed 's/%//')
    
    echo "Total Coverage: ${COVERAGE_PCT}%"
    
    # Save to file for badge generation
    echo "$COVERAGE_PCT" > "$COVERAGE_DIR/coverage-percentage.txt"
    
    print_success "Coverage: ${COVERAGE_PCT}%"
}

# Generate coverage badge
generate_badge() {
    print_step "Generating coverage badge..."
    
    COVERAGE_PCT=$(cat "$COVERAGE_DIR/coverage-percentage.txt")
    
    # Determine badge color based on coverage
    if (( $(echo "$COVERAGE_PCT >= 80" | bc -l) )); then
        COLOR="brightgreen"
    elif (( $(echo "$COVERAGE_PCT >= 60" | bc -l) )); then
        COLOR="yellow"
    else
        COLOR="red"
    fi
    
    # Create badge JSON
    cat > "$COVERAGE_DIR/badge.json" << EOF
{
    "schemaVersion": 1,
    "label": "coverage",
    "message": "${COVERAGE_PCT}%",
    "color": "$COLOR"
}
EOF
    
    # Create README badge markdown
    cat > "$COVERAGE_DIR/badge.md" << EOF
![Coverage](https://img.shields.io/badge/coverage-${COVERAGE_PCT}%25-${COLOR}.svg)
EOF
    
    print_success "Generated coverage badge (${COVERAGE_PCT}% - $COLOR)"
}

# Generate module-specific reports
generate_module_reports() {
    print_step "Generating module-specific coverage reports..."
    
    MODULES=("Core" "NLP" "Vision" "Speech" "ML" "Privacy" "Network" "Cache" "Metrics")
    
    for module in "${MODULES[@]}"; do
        echo "  Processing SwiftIntelligence${module}..."
        
        xcrun llvm-cov report \
            "$BINARY_PATH" \
            -instr-profile="$PROFDATA" \
            -ignore-filename-regex="Tests|Examples|DemoApps" \
            Sources/SwiftIntelligence${module} \
            > "$COVERAGE_DIR/coverage-${module}.txt" 2>/dev/null || true
    done
    
    print_success "Generated module-specific reports"
}

# Upload to Codecov (if in CI)
upload_codecov() {
    if [ -n "$CI" ]; then
        print_step "Uploading to Codecov..."
        
        if [ -f "$COVERAGE_DIR/coverage.lcov" ]; then
            # Download Codecov uploader
            curl -Os https://uploader.codecov.io/latest/macos/codecov
            chmod +x codecov
            
            # Upload coverage
            ./codecov \
                -f "$COVERAGE_DIR/coverage.lcov" \
                -F unittests \
                -n "SwiftIntelligence Coverage" \
                -v
            
            print_success "Uploaded to Codecov"
        else
            print_warning "No coverage data to upload"
        fi
    else
        print_warning "Not in CI environment, skipping Codecov upload"
    fi
}

# Generate final report
generate_final_report() {
    print_step "Generating final coverage report..."
    
    COVERAGE_PCT=$(cat "$COVERAGE_DIR/coverage-percentage.txt")
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    
    cat > "$COVERAGE_DIR/README.md" << EOF
# SwiftIntelligence Coverage Report

Generated: $TIMESTAMP

## Overall Coverage

![Coverage](https://img.shields.io/badge/coverage-${COVERAGE_PCT}%25-brightgreen.svg)

- **Total Coverage**: ${COVERAGE_PCT}%
- **Lines Covered**: See detailed report
- **Branches Covered**: See detailed report

## Reports

- [HTML Report](../docs/coverage/index.html)
- [LCOV Report](coverage.lcov)
- [JSON Report](coverage.json)
- [Text Summary](coverage-summary.txt)

## Module Coverage

| Module | Coverage |
|--------|----------|
EOF
    
    # Add module coverage to report
    for module in "${MODULES[@]}"; do
        if [ -f "$COVERAGE_DIR/coverage-${module}.txt" ]; then
            MODULE_COV=$(tail -1 "$COVERAGE_DIR/coverage-${module}.txt" 2>/dev/null | awk '{print $10}' || echo "N/A")
            echo "| SwiftIntelligence${module} | $MODULE_COV |" >> "$COVERAGE_DIR/README.md"
        fi
    done
    
    cat >> "$COVERAGE_DIR/README.md" << EOF

## How to View

### HTML Report
\`\`\`bash
open docs/coverage/index.html
\`\`\`

### Serve Locally
\`\`\`bash
cd docs/coverage && python3 -m http.server 8000
# Then open http://localhost:8000
\`\`\`

## CI/CD Integration

This report is automatically generated on each push to main branch.
Coverage data is uploaded to Codecov for tracking and PR comments.

## Coverage Goals

- **Overall Target**: 80%
- **Core Module**: 90%
- **AI/ML Modules**: 85%
- **Infrastructure**: 80%
EOF
    
    print_success "Generated final report"
}

# Main execution
main() {
    print_header
    
    check_dependencies
    clean_coverage
    run_tests
    generate_coverage_data
    generate_lcov
    generate_json
    generate_html
    generate_summary
    extract_coverage_percentage
    generate_badge
    generate_module_reports
    upload_codecov
    generate_final_report
    
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}           Coverage Report Generated Successfully!           ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "📊 Reports available at:"
    echo "   - HTML: $DOCS_DIR/index.html"
    echo "   - LCOV: $COVERAGE_DIR/coverage.lcov"
    echo "   - JSON: $COVERAGE_DIR/coverage.json"
    echo "   - Summary: $COVERAGE_DIR/README.md"
    echo ""
}

# Run main function
main "$@"