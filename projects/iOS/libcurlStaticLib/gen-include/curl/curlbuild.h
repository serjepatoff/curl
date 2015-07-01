#pragma once

#if __LP64__
#include <curl/curlbuild-arm64.h>
#else
#include <curl/curlbuild-armv7.h>
#endif