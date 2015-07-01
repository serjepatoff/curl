#pragma once

#if __LP64__

#if TARGET_IPHONE_SIMULATOR
#include <curl_config-x86_64.h>
#else
#include <curl_config-arm64.h>
#endif

#else

#if TARGET_IPHONE_SIMULATOR
#include <curl_config-i386.h>
#else
#include <curl_config-armv7.h>
#endif

#endif