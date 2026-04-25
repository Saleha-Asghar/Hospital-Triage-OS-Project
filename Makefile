# ==============================================================================
# Project : Hospital Patient Triage & Bed Allocator
# Group   : [Your Group Number]
# Members : Saleha Asghar (24F-0615) & [Teammate Name]
# Purpose : Build system for CL2006 OS Semester Project
# ==============================================================================

# Compiler and Flags
CC = gcc
CFLAGS = -Wall -Wextra -pthread -g
SRC_DIR = src
BIN_DIR = .

# Targets
all: admissions patient_simulator

# Compile Admissions Manager (Phase 2 core)
admissions: $(SRC_DIR)/admissions.c
	$(CC) $(CFLAGS) $(SRC_DIR)/admissions.c -o $(BIN_DIR)/admissions

# Compile Patient Simulator (The process spawned by fork/exec)
patient_simulator: $(SRC_DIR)/patient_simulator.c
	$(CC) $(CFLAGS) $(SRC_DIR)/patient_simulator.c -o $(BIN_DIR)/patient_simulator

# Run the Hospital Simulation (Phase 1 requirement)
run: all
	chmod +x scripts/start_hospital.sh
	./scripts/start_hospital.sh

# Test Target (Phase 1 automated stress-test requirement)
test: all
	chmod +x scripts/test_stress.sh
	./scripts/test_stress.sh

# Clean up binaries, objects, and logs
clean:
	rm -f $(BIN_DIR)/admissions $(BIN_DIR)/patient_simulator
	rm -f logs/*.txt
	@echo "Cleanup complete."

.PHONY: all clean run test
