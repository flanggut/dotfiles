function waitfordevice() {
  adb wait-for-device root
  while [[ $(adb shell -x "getprop sys.boot_completed") -ne 1 ]]; do
    sleep 2
  done
}
