#!/usr/bin/env bash
# Gera as pastas de plataforma (android/ios) e prepara o projeto.
set -e

flutter create --project-name organiza --org br.com.organiza --platforms=android,ios .

# Permissão de internet no manifesto principal (necessária em builds release).
MANIFEST=android/app/src/main/AndroidManifest.xml
if [ -f "$MANIFEST" ] && ! grep -q 'android.permission.INTERNET' "$MANIFEST"; then
  perl -0pi -e 's#<application#<uses-permission android:name="android.permission.INTERNET"/>\n    <application#' "$MANIFEST"
fi

flutter pub get
echo "Pronto! Execute: flutter run"
