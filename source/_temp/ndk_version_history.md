ndk version history

ndk r7开始支持API 14
ndk r10开始支持arm64(API 21)
ndk r15 头文件在sysroot和platforms/android-xx都有，r16移除了platforms/android-xx下的

# r19b (January 2019)
- Standalone toolchains are now unnecessary

# r18b (September 2018)
- gcc removed
- remove API 14 and API 15, no longer need to provide both a PIE and non-PIE executable

# r17c (June 2018)
- remove ARMv5(armeabi), mips, mips64
- 64-bit support by google play in August 2019

# 16b (December 2017)
- add Android 8.1

# 15c (July 2017)
- remove android 2.3(API 9), min API is Android 4.0(API 14)
- add Android 8.0

# 14b (March 2017)
- gcc deprecation

# 13b (October 2016)
- add simpleperf
- ndk toolchain defaults to clang

# 12b (June 2016)

# 12 (June 2016)
- remove sysroots for prior Android 2.3(API 9)

# 11c (March 2016)

# 11b (March 2016)

# 11 (March 2016)
- strongly recommend switching to clang
- clang update to 3.8
- gcc deprecated
- remove gcc 4.8, use gcc 4.9


# 10e (May 2015)
- add clang 3.6
- remove clang 3.4
- remove gcc 4.6

# 10d (December 2014)
- gcc 4.8 default for 32-bit ABIs
- starting from API level 21, to use -fPIE -pie when building. In API levels 16 and higher, ndk-build uses PIE when building

# 10c (October 2014)
- add clang 3.5
- remove clang 3.3
- deprecated gcc 4.6

# 10b (September 2014)

# 10 (July 2014)
- add arm64-v8a, x86_64, mips64
- Android-L is the first level with 64-bit support
- add GCC 4.9 toolchain

# 9d (March 2014)
- add Clang 3.4

# 9c (December 2013)

# 9b (October 2013)
- add Android 19

# 9 (July 2013)
- add Android 4.3(API 18)
- add OpenGL ES 3.0(support Android 4.3)
- add GCC 4.8(default 4.6)
- add clang 3.3

# 8e (March 2013)
- add 64-bit toolchain set

# 8d (December 2012)
- add gcc 4.7

# 8c (November 2012)

# 8b (July 2012)
- add GCC 4.6 toolchain

# 8 (May 2012)
- add mips


# 7c (April 2012)

# 7b (February 2012)

# 7 (November 2011)
- add Android 4.0(API 14)

# 6b (August 2011)

# 6 (July 2011)
- add x86
- add APP_ABI all


# 5c (June 2011)

# 5b (January 2011)

# 5 (December 2010)
- add native activities

# 4b (June 2010)
- add ndk-build
- add ndk-gdb
- add armeabi-v7a
- add cpufeatures, can check ARMv7-A/VFPv3-D32/NEON support
- add sample application use cpufeatures optimized NEON
- add Android 2.2, support access pixel buffers of Bitmap from native

# 3 (March 2010)
- OpenGL ES 2.0
- sample application with gl2 vertext and fragment shaders
- add GCC 4.4.0

# 2 (September 2009)
- OpenGL ES 1.1
- OpenGL ES sample application with GLSurfaceView

# 1 (June 2009)
- GCC 4.2.1
- ARMv5TE
- system headers, document, sample applications