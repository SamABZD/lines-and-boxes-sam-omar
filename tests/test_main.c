#include "test.h"

#include <stdio.h>
#include <stdlib.h>

static unsigned checks;

void test_check(bool condition, const char *expression, const char *file, int line)
{
    ++checks;
    if (!condition) {
        fprintf(stderr, "%s:%d: failed: %s\n", file, line, expression);
        exit(EXIT_FAILURE);
    }
}

int main(void)
{
    test_board();
    test_input();
    printf("PASS: %u checks\n", checks);
    return EXIT_SUCCESS;
}
