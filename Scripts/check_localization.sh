#!/bin/bash
# Ensure all .strings files share the same keys
BASE="AstroStackerPro/Localization/Base.lproj/Localizable.strings"
for f in AstroStackerPro/Localization/*.lproj/Localizable.strings; do
  diff <(cut -d '=' -f1 "$BASE" | sort) <(cut -d '=' -f1 "$f" | sort) || exit 1
done
