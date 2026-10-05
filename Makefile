.PHONY: get analyze test android-apk android-aab ios-app ios-ipa run-android run-ios clean

get:
	flutter pub get
analyze:
	flutter analyze
test:
	flutter test

# --- separate per-platform builds ---
android-apk:
	scripts/build_android.sh apk
android-aab:
	scripts/build_android.sh aab
ios-app:
	scripts/build_ios.sh app
ios-ipa:
	scripts/build_ios.sh ipa

run-android:
	flutter run -d android
run-ios:
	flutter run -d ios
clean:
	flutter clean
