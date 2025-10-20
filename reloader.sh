#!/bin/bash

if [ $# -lt 2 ]; then
    echo -e "reloader.sh by @Fynjirby\n"
    echo "Usage: $0 <file-to-watch> <application-to-reload>"
    echo "Example: $0 ~/.config/waybar/config.jsonc waybar"
    echo "Log: ~/reloader.log"
    exit 1
fi

file="$1"
app="$2"
log="$HOME/reloader.log"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Reloader started for $app watching $file" | tee -a "$log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] To see extended log open ~/reloader.log"

while true; do
    inotifywait -e close_write "$file" >/dev/null 2>&1
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Detected change in $file" | tee -a "$log"

    pid=$(pgrep -x "$app")
    if [ -n "$pid" ]; then
        kill "$pid"
        wait "$pid" 2>/dev/null
    fi

    "$app" >> "$log" 2>&1 &
    new_pid=$!
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Reloaded $app" | tee -a "$log" 
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] New PID is $new_pid"
done
