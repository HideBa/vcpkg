# FlatCityBuf C++ bindings distribute a Rust-compiled static library that cannot be
# built from source via vcpkg. Building from source requires a Rust toolchain and
# cargo; upstream issue tracking a proper from-source build:
# https://github.com/cityjson/flatcitybuf
set(VCPKG_BUILD_TYPE release)

set(FCB_VERSION "0.7.4")

if(VCPKG_TARGET_IS_WINDOWS)
    if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        message(FATAL_ERROR "${PORT} only supports x64 on Windows.")
    endif()
    set(FCB_ASSET "fcb_cpp-windows-x86_64.zip")
    set(FCB_SHA512 "8e9e80969f5dd80a0ee6120c1d3a7bb2deb0d674f7baa71196cc62ce8b7e3dad6d43b348166ddb91432c726d4e0ed5a2970daf829de3aecd8ed4d8600e74991b")
elseif(VCPKG_TARGET_IS_OSX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FCB_ASSET "fcb_cpp-macos-aarch64.tar.gz")
        set(FCB_SHA512 "39d8f1bff0af41089597b104bd7555d08ac6ce95fd989bcd33eb170bf9f804e776e695e626b9ee5d67e5f0dcb769bf5a056362a49893b27b51baaaae25ff77ee")
    else()
        set(FCB_ASSET "fcb_cpp-macos-x86_64.tar.gz")
        set(FCB_SHA512 "5bc44592495d1ad3a3e6dd8abe4d3c417af9a2547e2550c1ad00f73da8ab4c017a123b48194ab75e40ca879b2d5540b9ea020bfac636823ca02081721ec734dc")
    endif()
elseif(VCPKG_TARGET_IS_LINUX)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(FCB_ASSET "fcb_cpp-linux-aarch64.tar.gz")
        set(FCB_SHA512 "489954a89760a4d4557b546333ddd259d3ccc5d82a34689b7f4d11b1e5141419b52900916f3f50f71e57ebd939354b47db28654de53a4520a3a35a25e015ee12")
    else()
        set(FCB_ASSET "fcb_cpp-linux-x86_64.tar.gz")
        set(FCB_SHA512 "8a12f9b7bd0d04c54f2f8099834dd1bd7a31c56065d70bc5c8631c0c429531b7ea2d9d240243b7e5856530419fd29325f5eb758ce97e69db46d7651449b2ec17")
    endif()
else()
    message(FATAL_ERROR "${PORT}: unsupported platform.")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/cityjson/flatcitybuf/releases/download/v${FCB_VERSION}/${FCB_ASSET}"
    FILENAME "${FCB_ASSET}"
    SHA512 "${FCB_SHA512}"
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL
    "${SOURCE_PATH}/fcb.h"
    "${SOURCE_PATH}/lib.rs.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/flatcitybuf"
)

file(INSTALL
    "${SOURCE_PATH}/lib.rs.cc"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${SOURCE_PATH}/fcb_cpp.lib"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
else()
    file(INSTALL "${SOURCE_PATH}/libfcb_cpp.a"
        DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
endif()

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/unofficial-flatcitybuf-config.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-flatcitybuf-config.cmake"
    @ONLY
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${CMAKE_CURRENT_LIST_DIR}/copyright")
