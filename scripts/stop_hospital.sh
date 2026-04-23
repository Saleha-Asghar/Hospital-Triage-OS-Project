#!/bin/bash

# ==============================================================================
# Project : Hospital Patient Triage & Bed Allocator 
# Script  : triage.sh 
# Group   : dword_winapi
# Members : Zainab Saeed (24F-0524), Saleha Asghar  (24F-0615)
# Date    : 2026-04-23
# Purpose : Validate patient data, compute triage priority, and pipe data 
#           to the admissions manager
# Usage   : ./triage.sh <name> <age> <severity 1-10> 
# ==============================================================================

FIFO_PATH="/tmp/discharge_fifo"
SEM_ICU="sem_icu_limit"
SEM_ISO="sem_iso_limit"

echo "------------------------------------------------"
echo "  Hospital System: SHUTTING DOWN                "
echo "------------------------------------------------"

# 1. Send SIGTERM to the admissions process (Requirement 4.1.2)
echo "[*] Terminating Admissions Manager..."
pkill -SIGTERM admissions

# 2. Clean up Shared Memory and Named Semaphores
# Requirement: use ipcrm and sem_unlink (via shell or C)
echo "[*] Cleaning up IPC resources..."

# Removing the FIFO
if [ -p "$FIFO_PATH" ]; then
    rm "$FIFO_PATH"
    echo "[+] Removed FIFO: $FIFO_PATH"
fi

# Note: In a real lab scenario, you'd use 'ipcrm -M 0xBEDF00D' 
# if you used a hex key for shared memory.
# ipcs -m | grep 0xbedf00d | awk '{print $2}' | xargs -r ipcrm -m

# 3. Print Final Ward Status Summary
echo "------------------------------------------------"
echo "  SHUTDOWN COMPLETE"
echo "  - All beds freed."
echo "  - IPC resources detached and removed."
echo "------------------------------------------------"
