#ifndef DOTS_TEST_H
#define DOTS_TEST_H

#include <stdbool.h>

void test_check(bool condition, const char *expression, const char *file, int line);
void test_board(void);
void test_input(void);

#define CHECK(expression) test_check((expression), #expression, __FILE__, __LINE__)

#endif
