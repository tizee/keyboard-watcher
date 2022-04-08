#ifndef KW_UTILS_H
#define KW_UTILS_H
#if DEBUG == 0
#define DebugLog(...)
#elif DEBUG == 1
#define DebugLog(...) NSLog(__VA_ARGS__)
#endif
#endif /* KW_UTILS_H */
