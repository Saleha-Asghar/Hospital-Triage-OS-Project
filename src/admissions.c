#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/sem.h>
#include <time.h>
#include "hospital.h"

#define SEM_KEY 715 
#define SHM_KEY 615 
#define FIFO_NAME "hospital_fifo"

void sem_lock(int semid)
{
    struct sembuf sb = {0, -1, 0};
    semop(semid, &sb, 1);
}

void sem_unlock(int semid)
{
    struct sembuf sb = {0, 1, 0};
    semop(semid, &sb, 1);
}
int find_highest_priority_patient(PatientRecord *queue)
{
    int best_index = -1;
    int highest_priority = 6;

    for (int i = 0; i < 50; i++)
    {
        if (queue[i].patient_id != 0)
        {
            if (queue[i].priority < highest_priority)
            {
                highest_priority = queue[i].priority;
                best_index = i;
            }
            else if (queue[i].priority == highest_priority)
            {
                if ((best_index == -1) || (queue[i].arrival_time < queue[best_index].arrival_time))
                {
                    best_index = i;
                }
            }
        }
    }
    return best_index;
}

int main() {
    int shmid = shmget(SHM_KEY, sizeof(PatientRecord) * 50, IPC_CREAT | 0666);

    PatientRecord *shared_queue = (PatientRecord *)shmat(shmid, NULL, 0);
    printf("Hospital Ward (SHM) Initialized at %p\n", (void*)shared_queue);

    int semid = semget(SEM_KEY, 1, IPC_CREAT | 0666);
    semctl(semid, 0, SETVAL, 1);
    printf("Semaphore (Lock) Initialized.\n");
    mkfifo(FIFO_NAME, 0666);
    char buffer[100];
    int fd;

    printf("Admissions Manager: Waiting for patients...\n");

    while (1)
    {
        fd = open(FIFO_NAME, O_RDONLY);
        if (read(fd, buffer, sizeof(buffer)) > 0)
        {
            char buffer_copy[100];
            strcpy(buffer_copy, buffer);

            printf("Admissions Manager: Parsing Data: %s\n", buffer);

            PatientRecord new_patient;
            char *token = strtok(buffer, ",");
            if (token != NULL)
            {
                strcpy(new_patient.name, token);
            }
            
            token = strtok(NULL, ",");
            if (token != NULL)
            {
                new_patient.age = atoi(token);
            }

            token = strtok(NULL, ",");
            if (token != NULL)
            {
                new_patient.severity = atoi(token);
            }

            token = strtok(NULL, ",");
            if (token != NULL) 
            {
                new_patient.priority = atoi(token);
            }
            new_patient.arrival_time = time(NULL);
            new_patient.patient_id = rand() % 1000 + 100;

            printf("Verified: Patient %s (Priority %d) ready.\n", new_patient.name, new_patient.priority);

            sem_lock(semid); 
            for (int i = 0; i < 50; i++)
            {
                if (shared_queue[i].patient_id == 0)
                { 
                    shared_queue[i] = new_patient;
                    printf("Success: %s added to shared memory slot %d\n", new_patient.name, i);
                    break;
                }
            }
            FILE *log_file = fopen("logs/schedule_logs.txt", "a");
            if (log_file)
            {
                fprintf(log_file, "[%ld] Patient %s (ID: %d) admitted with Priority %d\n", new_patient.arrival_time, new_patient.name, new_patient.patient_id, new_patient.priority);
                fclose(log_file);
            }

            sem_unlock(semid);
            sleep(2);

            sem_lock(semid);
            int next_patient_idx = find_highest_priority_patient(shared_queue);

            if (next_patient_idx != -1)
            {
                PatientRecord p = shared_queue[next_patient_idx];

                double wait_time = difftime(time(NULL), p.arrival_time);
                
                printf("SCHEDULER: Picking Patient %s (Priority %d) after waiting %.2f seconds.\n", p.name, p.priority, wait_time);
                shared_queue[next_patient_idx].patient_id = 0; 
            }
            sem_unlock(semid);
            
            if (fork() == 0)
            {
                char *args[] = {"./patient_simulator", buffer_copy, NULL};
                execv(args[0], args);
                exit(1);
            }
        }
        close(fd);

    }
    return 0;
}
