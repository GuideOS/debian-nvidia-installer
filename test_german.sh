#!/usr/bin/env bash

source "usr/lib/debian-nvidia-installer/translate/translator.sh"

tr::add "de_DE" "test.welcome" "Willkommen beim Test"

# Force German language
FORCE_LANG="de_DE"
tr::detect_language

echo "Current language: $SCRIPT_LANG"
echo "Test translation: $(tr::t "test.welcome")"
echo "Default button: $(tr::t "default.tui.button.ok")"
