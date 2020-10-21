#ifndef _LIBCCMINER_H_
#define _LIBCCMINER_H_

#include <stdarg.h>

#ifdef __cplusplus
extern "C"{
#endif //__cplusplus

int init(void(*cb)(const char *format, va_list arg));
int is_running();
int start(const char* url, const char* user, const char* pass, const int n_threads=0);
int stop();

#ifdef __cplusplus
}
#endif //__cplusplus

#endif