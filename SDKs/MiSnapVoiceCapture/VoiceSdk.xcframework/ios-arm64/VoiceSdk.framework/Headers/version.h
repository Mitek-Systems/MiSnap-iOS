#pragma once

#include <string>
#include <iostream>

#include <voicesdk/core/config.h>

#define VOICESDK_PROJECT_VERSION "3.7.2"
#define VOICESDK_COMPONENTS      "core media"
#define VOICESDK_GIT_INFO        "HEAD cc02de76 "

namespace voicesdk {

    /**
     * @brief Structure containing present VoiceSDK build info.
     */
    struct VOICE_SDK_API BuildInfo {
        /**
         * @brief VoiceSDK build version.
         */
        std::string version = VOICESDK_PROJECT_VERSION;

        /**
         * @brief VoiceSDK components present in build.
         */
        std::string components = VOICESDK_COMPONENTS;

        /**
         * @brief Git info dumped at the build stage.
         */
        std::string gitInfo = VOICESDK_GIT_INFO;

        /**
         * @brief Information (e.g. expiration date) about the installed license if available or
         * an empty string if no license is in use.
         */
        std::string licenseInfo;

        friend std::ostream &operator<<(std::ostream& os, const BuildInfo& obj) {
            os << "BuildInfo["
               << "version: \""     << obj.version     << "\", "
               << "components: \""  << obj.components  << "\", "
               << "gitInfo: \""     << obj.gitInfo     << "\", "
               << "licenseInfo: \"" << obj.licenseInfo << "\"]";
            return os;
        }
    };

    /**
     * @brief Returns present VoiceSDK build info.
     * @return Present VoiceSDK present build info.
     */
    VOICE_SDK_API BuildInfo getBuildInfo() noexcept;
}
