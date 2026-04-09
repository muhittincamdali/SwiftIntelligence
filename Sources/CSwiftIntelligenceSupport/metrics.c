#include "CSwiftIntelligenceSupport.h"

#include <mach/mach.h>

bool swiftintelligence_get_task_basic_info(
    uint64_t *resident_size,
    double *user_seconds,
    double *system_seconds
) {
    struct mach_task_basic_info info;
    mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;
    kern_return_t result = task_info(
        mach_task_self(),
        MACH_TASK_BASIC_INFO,
        (task_info_t)&info,
        &count
    );

    if (result != KERN_SUCCESS) {
        return false;
    }

    if (resident_size != NULL) {
        *resident_size = info.resident_size;
    }

    if (user_seconds != NULL) {
        *user_seconds = info.user_time.seconds + (info.user_time.microseconds / 1000000.0);
    }

    if (system_seconds != NULL) {
        *system_seconds = info.system_time.seconds + (info.system_time.microseconds / 1000000.0);
    }

    return true;
}
