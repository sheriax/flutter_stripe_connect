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

# Check the final validation result line
# Format: "Package has X warning(s) and Y hint(s)." or "Package has X warnings."
HAS_ISSUES=false

# Check if the output says "Package has 0 warnings." (which means all good)
if echo "$DRY_RUN_OUTPUT" | grep -q "Package has 0 warnings"; then
    # All good - no warnings
    :
else
    # Check for non-zero warnings: "Package has N warning" where N > 0
    # This matches lines like "Package has 1 warning." or "Package has 2 warnings."
    if echo "$DRY_RUN_OUTPUT" | grep -E "Package has [1-9][0-9]* warning" > /dev/null; then
        echo -e "${RED}✗ Dry run found warning(s)${NC}"
        HAS_ISSUES=true
    fi
fi

# Check for hints: "N hint" where N > 0
if echo "$DRY_RUN_OUTPUT" | grep -E "[1-9][0-9]* hint" > /dev/null; then
    echo -e "${RED}✗ Dry run found hint(s)${NC}"
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
    echo -e "${RED}✗ Publishing failed or cancelled${NC}"
    exit 1
fi
