#!/bin/bash

# Publish script for flutter_stripe_connect
# Runs flutter analyze, dart pub publish --dry-run, and publishes if both pass

echo "==================================="
echo "Flutter Stripe Connect Publish Script"
echo "==================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Flutter Analyze
echo -e "${YELLOW}Step 1: Running flutter analyze...${NC}"
echo ""

ANALYZE_OUTPUT=$(flutter analyze 2>&1)
ANALYZE_EXIT_CODE=$?

echo "$ANALYZE_OUTPUT"
echo ""

if [ $ANALYZE_EXIT_CODE -ne 0 ]; then
    echo -e "${RED}✗ Flutter analyze failed${NC}"
    echo "Please fix the issues above before publishing."
    exit 1
fi

echo -e "${GREEN}✓ Flutter analyze passed${NC}"
echo ""

# Step 2: Dart Pub Publish Dry Run
echo -e "${YELLOW}Step 2: Running dart pub publish --dry-run...${NC}"
echo ""

# Capture output (allow non-zero exit code)
DRY_RUN_OUTPUT=$(dart pub publish --dry-run 2>&1) || true

echo "$DRY_RUN_OUTPUT"
echo ""

# Check for any warnings, hints, or errors in the output
# The output format is: "Package has X warning(s) and Y hint(s)."
HAS_ISSUES=false

if echo "$DRY_RUN_OUTPUT" | grep -q "warning"; then
    echo -e "${RED}✗ Dry run found warning(s)${NC}"
    HAS_ISSUES=true
fi

if echo "$DRY_RUN_OUTPUT" | grep -q "hint"; then
    echo -e "${RED}✗ Dry run found hint(s)${NC}"
    HAS_ISSUES=true
fi

if echo "$DRY_RUN_OUTPUT" | grep -q -i "error"; then
    echo -e "${RED}✗ Dry run found error(s)${NC}"
    HAS_ISSUES=true
fi

if [ "$HAS_ISSUES" = true ]; then
    echo ""
    echo "Please fix all issues above before publishing."
    exit 1
fi

echo -e "${GREEN}✓ Dry run passed with no issues${NC}"
echo ""

# Step 3: Confirm and Publish
echo -e "${YELLOW}Step 3: Publishing to pub.dev...${NC}"
echo ""

# Check for --force flag
if [[ "$1" == "--force" ]]; then
    echo "Publishing with --force flag..."
    dart pub publish --force
else
    echo "Ready to publish. Run with --force to auto-confirm, or confirm below:"
    dart pub publish
fi

PUBLISH_EXIT_CODE=$?

if [ $PUBLISH_EXIT_CODE -eq 0 ]; then
    echo ""
    echo -e "${GREEN}==================================="
    echo "✓ Package published successfully!"
    echo "===================================${NC}"
else
    echo ""
    echo -e "${RED}✗ Publishing failed${NC}"
    exit 1
fi
