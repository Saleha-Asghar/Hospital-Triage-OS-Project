#ifndef HOSPITAL_H
#define HOSPITAL_H
#define TOTAL_BEDS 100

#include <time.h>

typedef struct{
	int patient_id;
	char name[64];
	int age;
	int severity;
	int priority;
	int care_units;
	time_t arrival_time;
	int assigned_bed_id;
} PatientRecord;


typedef struct{
	int partition_id;
	int start_unit;
	int size;
	int is_free;
	char bed_type[16];
} BedPartition;

typedef struct {
    int bed_id;
    int is_occupied;    // 0 = Free, 1 = Occupied
    int patient_id;     // ID of patient currently in this bed
    int start_unit;     // Starting index in the 100-unit block
    int num_units;      // How many units this patient occupies
} BedMapping;

typedef struct {
    PatientRecord queue[50];
    int bed_map[TOTAL_BEDS]; // 0 = Free, 1 = Occupied
    BedMapping active_assignments[50]; 
} HospitalWard;

#endif
