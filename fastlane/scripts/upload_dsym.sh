#!/bin/bash
set -e
DSYM=$(find ~/Library/Developer/Xcode/DerivedData -name "*.dSYM" | head -n 1)
if [ -n "$DSYM" ]; then
  upload-symbols -gsp AstroStackerPro/GoogleService-Info.plist -p ios "$DSYM" || true
fi
