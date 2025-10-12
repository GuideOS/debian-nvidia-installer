#!/usr/bin/env bash

source "usr/lib/debian-nvidia-installer/translate/translator.sh"

# Force German language
FORCE_LANG="de_DE"
tr::detect_language

echo "Current language: $SCRIPT_LANG"

# Try to add a German translation
tr::add "de_DE" "test.hello" "Hallo Welt"

echo "Test translation: $(tr::t "test.hello")"

# Check if the add was successful
echo "German array contents:"
for key in "${!T_DE_DE[@]}"; do
    echo "  $key: ${T_DE_DE[$key]}"
done
