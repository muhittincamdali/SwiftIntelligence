#ifndef CSWIFTINTELLIGENCESUPPORT_H
#define CSWIFTINTELLIGENCESUPPORT_H

#include <stdbool.h>
#include <stdint.h>

bool swiftintelligence_get_task_basic_info(
    uint64_t *resident_size,
    double *user_seconds,
    double *system_seconds
);

#endif
