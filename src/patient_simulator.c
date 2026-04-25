#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <Patient_Data>\n", argv[0]);
        return 1;
    }

    printf("Patient Simulator [PID %d]: Treatment started for %s\n", getpid(), argv[1]);

    // To make it interesting, let's pick a random treatment time between 5-15 seconds
    srand(time(NULL) ^ getpid()); 
    int treatment_time = (rand() % 11) + 5; 

    printf("Patient Simulator [PID %d]: Occupying bed for %d seconds...\n", getpid(), treatment_time);
    
    // This 'sleep' simulates the patient using hospital resources (Memory/Beds)
    sleep(treatment_time); 

    printf("Patient Simulator [PID %d]: Treatment complete. Releasing resources and exiting.\n", getpid());
    
    return 0;
}
