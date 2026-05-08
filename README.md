# Hospital Triage Operating System Simulation

This project simulates an Operating System kernel managing hospital resources using IPC, Scheduling, and Memory Management algorithms.

## Features
- **Phase 1-2 (IPC):** Uses **Named Pipes (FIFO)** for patient intake and **Shared Memory** for state management.
- **Phase 3 (Scheduling):** Implements a **Non-Preemptive Priority Scheduler**. High-severity patients are prioritized over others regardless of arrival time.
- **Phase 4 (Memory):** Implements **Best-Fit Memory Allocation**. The system searches for the smallest available contiguous bed block to minimize fragmentation.
- **Phase 5 (Reporting):** Automated logging and performance analysis script to calculate throughput and average wait times.

## How to Run
1. **Compile:** `make all`
2. **Start Manager:** `./admissions`
3. **Add Patients:** `./scripts/triage.sh "PatientName" Age Severity(1-10)`
4. **View Report:** `./performance_report.sh`
5. **Clean Shutdown:** `Ctrl+C` in the admissions terminal or `./scripts/stop_hospital.sh`
