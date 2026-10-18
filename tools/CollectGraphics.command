#!/bin/bash
# Run on the installed E3 macOS desktop. Read diagnostics only; change no settings.
case "${OSTYPE-}" in darwin*) ;; *) printf 'Run this file on the E3 macOS desktop.\n'; exit 1 ;; esac
if [ ! -d /System/Library/CoreServices/Finder.app ]; then
    printf 'Use the installed macOS desktop, not Recovery.\n'
    exit 1
fi
umask 077
e3_stamp=$(/bin/date +%Y%m%d-%H%M%S)
e3_name="E3-Graphics-${e3_stamp}-$$"
e3_out="$HOME/Desktop/$e3_name"
/bin/mkdir -p "$e3_out/panic-reports" || exit 1
printf 'Collecting graphics and crash reports. Please wait...\n'

# Bound potentially slow macOS reporting commands; a hung collector must not block.
e3_capture() {
    e3_file=$1
    shift
    "$@" > "$e3_out/$e3_file" 2>&1 &
    e3_pid=$!
    (
        /bin/sleep 25
        /bin/kill -TERM "$e3_pid" 2>/dev/null
    ) &
    e3_timer=$!
    wait "$e3_pid"
    e3_rc=$?
    /bin/kill "$e3_timer" 2>/dev/null
    wait "$e3_timer" 2>/dev/null
    printf '%s: exit %s\n' "$e3_file" "$e3_rc" >> "$e3_out/collection-status.txt"
}

e3_capture macos-version.txt /usr/bin/sw_vers
e3_capture active-boot-args.txt /usr/sbin/sysctl kern.bootargs
e3_capture displays.txt /usr/sbin/system_profiler SPDisplaysDataType
e3_capture ioaccelerator.txt /usr/sbin/ioreg -r -c IOAccelerator -l
e3_capture intelaccelerator.txt /usr/sbin/ioreg -r -c IntelAccelerator -l
e3_capture ioreg-service.txt /usr/sbin/ioreg -lw0 -p IOService
e3_capture ioreg-device-tree.txt /usr/sbin/ioreg -lw0 -p IODeviceTree
e3_capture loaded-kexts.txt /usr/sbin/kextstat -l
e3_capture native-hd4000-info.txt /usr/libexec/PlistBuddy -c Print /System/Library/Extensions/AppleIntelHD4000Graphics.kext/Contents/Info.plist
e3_capture native-hd4000-files.txt /bin/ls -ld \
    /System/Library/Extensions/AppleIntelHD4000Graphics.kext/Contents/MacOS/AppleIntelHD4000Graphics \
    /System/Library/Extensions/AppleIntelHD4000GraphicsMTLDriver.bundle \
    /System/Library/Extensions/AppleIntelHD4000GraphicsGLDriver.bundle
e3_capture hd4000-load-errors.txt /usr/bin/log show --last 24h --style compact \
    --predicate 'eventMessage CONTAINS[c] "AppleIntelHD4000Graphics"'
e3_capture kernel-buffer.txt /sbin/dmesg
e3_capture reduce-transparency.txt /usr/bin/defaults read com.apple.universalaccess reduceTransparency
e3_capture increase-contrast.txt /usr/bin/defaults read com.apple.universalaccess increaseContrast
e3_capture graphics-kernel-last-24h.txt /usr/bin/log show --last 24h --style compact \
    --predicate '(process == "kernel" AND (eventMessage CONTAINS[c] "panic" OR eventMessage CONTAINS[c] "Capri" OR eventMessage CONTAINS[c] "IntelHD" OR eventMessage CONTAINS[c] "IOGraphics" OR eventMessage CONTAINS[c] "stolen" OR eventMessage CONTAINS[c] "WhateverGreen" OR eventMessage CONTAINS[c] "Lilu" OR eventMessage CONTAINS[c] "IMEI")) OR (process == "WindowServer" AND messageType == fault)'

e3_count=0
for e3_base in /Library/Logs/DiagnosticReports "$HOME/Library/Logs/DiagnosticReports"; do
    [ -d "$e3_base" ] || continue
    while IFS= read -r -d '' e3_report; do
        e3_count=$((e3_count + 1))
        if [ -r "$e3_report" ]; then
            /bin/cp -p "$e3_report" "$e3_out/panic-reports/${e3_count}-$(/usr/bin/basename "$e3_report")" 2>> "$e3_out/collection-status.txt"
        else
            printf 'Unreadable crash report: %s\n' "$e3_report" >> "$e3_out/collection-status.txt"
        fi
    done < <(/usr/bin/find "$e3_base" -maxdepth 2 -type f -mtime -7 \
        \( -iname '*.panic' -o -iname '*panic*.ips' -o -iname '*Kernel*.ips' -o -iname '*WindowServer*.crash' -o -iname '*WindowServer*.ips' -o -iname '*gpuRestart*' \) -print0 2>> "$e3_out/collection-status.txt")
done
printf 'Matching report candidates: %s\n' "$e3_count" >> "$e3_out/collection-status.txt"

# OpenCore may have saved a panic on an already-mounted EFI. Do not mount disks.
e3_esp_count=0
for e3_volume in /Volumes/*; do
    [ -d "$e3_volume/EFI/OC" ] || continue
    e3_esp_count=$((e3_esp_count + 1))
    for e3_panic in "$e3_volume"/panic-*.txt; do
        [ -r "$e3_panic" ] || continue
        /bin/cp -p "$e3_panic" "$e3_out/panic-reports/esp-${e3_esp_count}-$(/usr/bin/basename "$e3_panic")" 2>> "$e3_out/collection-status.txt"
    done
done

printf 'Generated: %s\nThis collection reads diagnostics only.\nA missing report is recorded in collection-status.txt.\n' "$e3_stamp" > "$e3_out/README.txt"
e3_zip="$HOME/Desktop/${e3_name}.zip"
if /usr/bin/ditto -c -k --keepParent "$e3_out" "$e3_zip"; then
    printf '\nDone. Send this ZIP back in the chat:\n%s\n' "$e3_zip"
    /usr/bin/open -R "$e3_zip"
else
    printf '\nZIP creation failed; reports remain here:\n%s\n' "$e3_out"
fi
printf '\nPress Enter to close. '
IFS= read -r e3_reply
