#!/bin/bash

# ==============================================================================
# Project : Hospital Patient Triage & Bed Allocator 
# Script  : triage.sh 
# Group   : dword_winapi
# Members : Zainab Saeed (24F-0524), Saleha Asghar  (24F-0615)
# Date    : 2026-04-23
# Purpose : Validate patient data, compute triage priority, and pipe data 
#           to the admissions manager
# Usage   : ./triage.sh <name> <age> <severity 1-10> 
# ==============================================================================

# 1. Define IPC Keys/Paths
SHM_KEY="0xBEDF00D"
SEM_ICU="/sem_icu_limit"
SEM_ISO="/sem_iso_limit"
FIFO_PATH="/tmp/discharge_fifo"

echo "------------------------------------------------"
echo "  Hospital System: STARTING INITIALIZATION      "
echo "------------------------------------------------"

# 2. Create the Named FIFO if it doesn't exist (Required for Phase 2B)
if [ ! -p "$FIFO_PATH" ]; then
    mkfifo "$FIFO_PATH"
    echo "[+] Created Named FIFO at $FIFO_PATH"
fi

# 3. Print Startup Banner showing Ward Capacity (Requirement 4.1.2)
echo "[*] Initializing Ward Capacity..."
echo "    - ICU Beds: 4"
echo "    - Isolation Beds: 4"
echo "    - General Ward Beds: 12"
echo "------------------------------------------------"

# 4. Launch the Admissions Manager in the background
# Note: For now, we assume the binary is in the parent directory or bin/
if [ -f "../admissions" ]; then
    ../admissions & 
    echo "[+] Admissions Manager launched in background (PID: $!)"
else
    echo "[!] Error: admissions binary not found. Please run 'make' first."
    exit 1
fi

echo "[*] System is ready to receive patients via triage.sh"
