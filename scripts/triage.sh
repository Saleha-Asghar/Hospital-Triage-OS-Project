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

# 1. Check if the correct number of arguments is provided 
if [ "$#" -ne 3 ]; then
    echo "Error: Invalid number of arguments."
    echo "Usage: $0 <name> <age> <severity 1-10>"
    exit 1
fi

NAME=$1
AGE=$2
SEVERITY=$3

# 2. Validation 
# Check if Name is non-empty
if [ -z "$NAME" ]; then
    echo "Error: Patient name cannot be empty."
    exit 1
fi

# Check if Age is a number and within range
if ! [[ "$AGE" =~ ^[0-9]+$ ]] || [ "$AGE" -lt 0 ] || [ "$AGE" -gt 120 ]; then
    echo "Error: Invalid age. Please enter a number between 0 and 120."
    exit 1
fi

# Check if Severity is a number between 1 and 10
if ! [[ "$SEVERITY" =~ ^[0-9]+$ ]] || [ "$SEVERITY" -lt 1 ] || [ "$SEVERITY" -gt 10 ]; then
    echo "Error: Severity must be a number between 1 and 10."
    exit 1
fi

# 3. Priority Mapping (1-5) 
# Mapping logic: Higher severity = Lower priority number (Critical)
if [ "$SEVERITY" -ge 9 ]; then
    PRIORITY=1 # Critical
elif [ "$SEVERITY" -ge 7 ]; then
    PRIORITY=2 # Urgent
elif [ "$SEVERITY" -ge 5 ]; then
    PRIORITY=3 # Normal
elif [ "$SEVERITY" -ge 3 ]; then
    PRIORITY=4 # Minor
else
    PRIORITY=5 # Routine
fi

# 4. Output and Pipe to Admissions Manager
# Format: name,age,severity,priority
PATIENT_RECORD="$NAME,$AGE,$SEVERITY,$PRIORITY"

echo "Success: Patient Record Created"
echo "-------------------------------"
echo "Record: $PATIENT_RECORD"

# In the final system, you will uncomment the line below to send data to the C program:
# echo "$PATIENT_RECORD" > /tmp/admissions_pipe
# Format the data into a single string
PATIENT_DATA="$NAME,$AGE,$SEVERITY,$PRIORITY"

# Send it to the Named Pipe
# Note: Ensure the path points to the FIFO in your project root
echo "$PATIENT_DATA" > hospital_fifo

echo "Triage Complete: Data for $NAME sent to Admissions Manager."
