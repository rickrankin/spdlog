#!/bin/bash

astyleOptions=(
  "--options=none"                  # Ignore existing .astylerc
  "--suffix=none"                   # Don't backup the original file
  "--style=break"                   # Brace style
  "--convert-tabs"                  # Convert tabs to spaces
)
find . \( -name "*.h" -o -name "*.cpp" \) -exec dos2unix {} +
find . \( -name "*.h" -o -name "*.cpp" \) -exec astyle "${astyleOptions[@]}" {} +
