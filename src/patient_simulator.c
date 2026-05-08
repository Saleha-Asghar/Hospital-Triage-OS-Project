#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include "hospital.h" // Ensure this has the HospitalWard struct

// Helper for Semaphore (The lock)
void sem_op(int semid, int op) {
    struct sembuf sb = {0, op, 0};
    semop(semid, &sb, 1);
}

int main(int argc, char *argv[]) {
    // We now need 3 args: program_name, patient_name, bed_info
    if (argc < 3) {
        printf("Usage: %s <Name> <start_unit,num_units>\n", argv[0]);
        return 1;
    }

    // 1. Parse the Bed Info passed from Admissions
    int start_unit, num_units;
    sscanf(argv[2], "%d,%d", &start_unit, &num_units);

    // 2. Attach to Shared Memory (Key 615) and Semaphore (Key 715)
    int shmid = shmget(615, sizeof(HospitalWard), 0666);
    int semid = semget(715, 1, 0666);
    HospitalWard *ward = (HospitalWard *)shmat(shmid, NULL, 0);

    printf("Patient Simulator [PID %d]: Treatment started for %s\n", getpid(), argv[1]);
    
    srand(time(NULL) ^ getpid()); 
    int treatment_time = (rand() % 11) + 5; 
    printf("Patient Simulator [PID %d]: Occupying %d units from index %d for %d seconds...\n", 
            getpid(), num_units, start_unit, treatment_time);
    
    // Simulate recovery
    sleep(treatment_time); 

    // 3. THE RELEASE (Phase 4 Logic)
    printf("Patient Simulator [PID %d]: Releasing beds...\n", getpid());
    
    sem_op(semid, -1); // LOCK: Wait for my turn to edit the map
    
    for (int i = 0; i < num_units; i++) {
        ward->bed_map[start_unit + i] = 0; // Set beds back to FREE (0)
    }
    
    sem_op(semid, 1);  // UNLOCK: Done editing
    
    shmdt(ward); // Detach memory
    printf("Patient Simulator [PID %d]: Resources released. Exiting.\n", getpid());
    
    return 0;
}
