#!/usr/bin/env bash

flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/app_localizations.dart
cat lib/l10n/intl_messages.arb > lib/l10n/intl_en.arb
cat lib/l10n/intl_messages.arb > lib/l10n/intl_es.arb
flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/app_localizations.dart lib/l10n/intl_*.arb
