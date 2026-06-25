#!/bin/sh
flutter build web
python -m http.server 8080 --directory build/web
