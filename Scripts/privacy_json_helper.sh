#!/bin/bash
# Simple helper to generate App Privacy details JSON skeleton
cat <<JSON
{
  "DataTypes": [
    {"Category": "Analytics", "Type": "Crash Data", "ThirdParty": "Firebase"},
    {"Category": "Usage", "Type": "Performance", "ThirdParty": "None"}
  ]
}
JSON
