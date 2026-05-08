#!/bin/bash

LOG_FILE="logs/schedule_logs.txt"

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file not found. Run the project and admit patients first."
    exit 1
fi

echo "================================================"
echo "      HOSPITAL PERFORMANCE REPORT (PHASE 5)     "
echo "================================================"

# 1. Count Total Patients
TOTAL_PATIENTS=$(grep -c "DISPATCH" "$LOG_FILE")
echo "Total Patients Treated: $TOTAL_PATIENTS"
# In performance_report.sh, change this line if needed:
TOTAL_PATIENTS=$(grep -c "DISPATCH" "$LOG_FILE")

# To match whatever word you used in admissions.c, like:
TOTAL_PATIENTS=$(grep -c "ADMITTED" "$LOG_FILE")

# 2. Calculate Average Wait Time
# This grabs the 'Wait Time' numbers and uses 'bc' to calculate the average
AVG_WAIT=$(grep "Wait Time" "$LOG_FILE" | awk '{sum+=$12; count++} END {if (count > 0) print sum/count; else print 0}')
echo "Average Wait Time:    $AVG_WAIT seconds"

# 3. Priority Breakdown
echo "------------------------------------------------"
echo "Performance by Priority:"
for i in {1..9}
do
    P_COUNT=$(grep -c "Priority: $i" "$LOG_FILE")
    P_WAIT=$(grep "Priority: $i" "$LOG_FILE" | awk '{sum+=$12; count++} END {if (count > 0) print sum/count; else print "N/A"}')
    echo " Priority $i: $P_COUNT patients | Avg Wait: $P_WAIT sec"
done
echo "================================================"
