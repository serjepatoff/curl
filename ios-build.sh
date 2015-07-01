#!/bin/sh

export CURRENTPATH=`pwd`
export LOGFILE="${CURRENTPATH}/build.log"
export SDK_VERSION="8.3"
#export ARCHS="arm64 armv7 armv7s i386 x86_64"
export ARCHS="x86_64"
export IPHONEOS_DEPLOYMENT_TARGET="4.3"
export CC="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"

export FEATURES='''--disable-ftp --disable-gopher --disable-imap --disable-smtp --disable-smb --disable-telnet --disable-tftp --disable-unix-sockets --disable-ldap --disable-ldaps --disable-rtsp --disable-pop3 --disable-manual --disable-file --disable-libcurl-option --disable-curldebug --disable-debug --disable-unix-sockets --enable-optimize'''
export SOURCES='''amigaos.c asyn-ares.c non-ascii.c base64.c conncache.c connect.c content_encoding.c cookie.c curl_addrinfo.c curl_des.c curl_endian.c curl_fnmatch.c curl_gethostname.c curl_gssapi.c curl_memrchr.c curl_multibyte.c curl_ntlm.c curl_ntlm_core.c curl_ntlm_msgs.c curl_ntlm_wb.c curl_rtmp.c curl_sasl.c curl_sasl_gssapi.c curl_sasl_sspi.c curl_sspi.c curl_threads.c dict.c dotdot.c easy.c escape.c file.c fileinfo.c formdata.c ftp.c ftplistparser.c getenv.c getinfo.c gopher.c hash.c hmac.c hostasyn.c hostcheck.c hostip.c hostip4.c hostip6.c hostsyn.c http.c http2.c http_chunks.c http_digest.c http_negotiate.c http_negotiate_sspi.c http_proxy.c idn_win32.c if2ip.c imap.c inet_ntop.c inet_pton.c krb5.c ldap.c llist.c md4.c md5.c memdebug.c mprintf.c multi.c netrc.c nonblock.c openldap.c parsedate.c pingpong.c pipeline.c pop3.c progress.c rawstr.c rtsp.c security.c select.c sendf.c share.c slist.c smb.c smtp.c socks.c socks_gssapi.c socks_sspi.c speedcheck.c splay.c ssh.c strdup.c strequal.c strerror.c strtok.c strtoofft.c telnet.c tftp.c asyn-thread.c timeval.c transfer.c url.c version.c vtls/axtls.c vtls/cyassl.c vtls/darwinssl.c vtls/gskit.c vtls/gtls.c vtls/nss.c vtls/openssl.c vtls/polarssl.c vtls/polarssl_threadlock.c vtls/schannel.c vtls/vtls.c warnless.c wildcard.c x509asn1.c'''

echo "Start" | tee ${LOGFILE}
mkdir ./lib/ios

for ARCHH in ${ARCHS}
do
	if [[ "${ARCHH}" == "i386" || "${ARCHH}" == "x86_64" ]];
    then
        export PLATFORM="iPhoneSimulator"
        export CPPFLAGS="-D__IPHONE_OS_VERSION_MIN_REQUIRED=${IPHONEOS_DEPLOYMENT_TARGET%%.*}0000"
    else
        export PLATFORM="iPhoneOS"
    fi

	echo "******** Building libcurl for ${PLATFORM} ${SDK_VERSION} ${ARCHH}" | tee -a ${LOGFILE}

	export CFLAGS="-arch ${ARCHH} -pipe -Os -g0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDK_VERSION}.sdk"
	export LDFLAGS="-arch ${ARCHH} -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDK_VERSION}.sdk"

	XARCH="${ARCHH}"
    if [ "${XARCH}" == "arm64" ];
    then
        XARCH="aarch64"
    fi

	#echo "******** Configuring libcurl for ${PLATFORM} ${SDK_VERSION} ${XARCH} ********" | tee -a ${LOGFILE}
	#./configure --disable-shared --enable-static --host="${XARCH}-apple-darwin" --with-darwinssl --enable-threaded-resolver ${FEATURES}

	cd lib
	$CC -c $CPPFLAGS $CFLAGS -DBUILDING_LIBCURL -DCURL_STATICLIB -DHAVE_CONFIG_H -DCURL_HIDDEN_SYMBOLS -I../include/curl -I../include -I../lib -fvisibility=hidden $SOURCES
	ar cru libcurl-${ARCHH}.a `find . -type f | grep "\.o$"`
	rm -f *.o
	cd $CURRENTPATH
done

cd lib
lipo -create -output libcurl.a libcurl-*
cd $CURRENTPATH

X='''for ARCHH in ${ARCHS}
do
	if [[ "${ARCHH}" == "i386" || "${ARCHH}" == "x86_64" ]];
    then
        export PLATFORM="iPhoneSimulator"
        export CPPFLAGS="-D__IPHONE_OS_VERSION_MIN_REQUIRED=${IPHONEOS_DEPLOYMENT_TARGET%%.*}0000"
    else
        export PLATFORM="iPhoneOS"
    fi

	echo "******** Building libcurl for ${PLATFORM} ${SDK_VERSION} ${ARCHH}" | tee -a ${LOGFILE}

	export CFLAGS="-arch ${ARCHH} -pipe -O0 -gdwarf-2 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDK_VERSION}.sdk"
	export LDFLAGS="-arch ${ARCHH} -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDK_VERSION}.sdk"

	XARCH="${ARCHH}"
    if [ "${XARCH}" == "arm64" ];
    then
        XARCH="aarch64"
    fi

	echo "******** Configuring libcurl for ${PLATFORM} ${SDK_VERSION} ${XARCH} ********" | tee -a ${LOGFILE}
	./configure --disable-shared --enable-static --host="${XARCH}-apple-darwin" --with-darwinssl --enable-threaded-resolver ${DISABLED_FEATURES}

	echo "******** Making libcurl for ${PLATFORM} ${SDK_VERSION} ${XARCH} ********" | tee -a ${LOGFILE}
	make -j `sysctl -n hw.logicalcpu_max`

	echo "******** Copying libcurl for ${PLATFORM} ${SDK_VERSION} ${XARCH} ********" | tee -a ${LOGFILE}
	cp ./lib/.libs/libcurl.a ./lib/ios/libcurl-${ARCHH}.a

	echo "******** Cleaning libcurl for ${PLATFORM} ${SDK_VERSION} ${XARCH} ********" | tee -a ${LOGFILE}
	make clean
done

pushd ./lib/ios
lipo -create -output libcurl.a libcurl*





CURRENTPATH=`pwd`
SDK_VERSION="8.3"
MIN_VERSION="6.0"
ARCHS="armv7s arm64 i386 x86_64"
XCODEPATH=`xcode-select -print-path`
LOGFILE="${CURRENTPATH}/build.log"
DISABLED_FEATURES="--disable-ftp --disable-gopher --disable-imap --disable-smtp --disable-smb --disable-telnet --disable-tftp --disable-unix-sockets --disable-ldap --disable-ldaps --disable-rtsp --disable-pop3 --disable-manual --disable-file"

set -e

echo "Start" | tee ${LOGFILE}

for ARCH in ${ARCHS}
do
    if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]];
    then
        PLATFORM="iPhoneSimulator"
    else
        PLATFORM="iPhoneOS"
    fi
    
    echo "******** Building libcurl for ${PLATFORM} ${SDK_VERSION} ${ARCH}" | tee -a ${LOGFILE}
    
    export SDKROOT="${XCODEPATH}/Platforms/${PLATFORM}.platform/Developer/SDKs/${PLATFORM}${SDK_VERSION}.sdk"

    export CPP="${XCODEPATH}/Toolchains/XcodeDefault.xctoolchain/usr/bin/cpp"
    export CC="${XCODEPATH}/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang"
    export CFLAGS="-arch ${ARCH} -pipe -Os -g0 -isysroot ${SDKROOT}"
    export CPPFLAGS="-D__IPHONE_OS_VERSION_MIN_REQUIRED=60000"
    export LDFLAGS="-arch ${ARCH} -isysroot ${SDKROOT}"

    ./configure --disable-shared --enable-static --host="${ARCH}-apple-darwin" --with-darwinssl --enable-threaded-resolver ${DISABLED_FEATURES}
    make -j`sysctl -n hw.logicalcpu_max`
done

echo "Building done." | tee -a ${LOGFILE}'''