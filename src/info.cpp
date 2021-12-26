/* This file is part of the the dci project. Copyright (C) 2013-2021 vopl, shtoba.
   This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public
   License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
   You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. */

#include <dci/integration/info.hpp>
#include <string>
#include <ctime>

namespace dci::integration::info
{
#define CAT0(x,y) x##y
#define CAT(x,y) CAT0(x,y)

    using namespace std::literals::string_view_literals;

    /////////0/////////1/////////2/////////3/////////4/////////5/////////6/////////7
    std::string_view srcBranch()
    {
#if defined(DCI_SRC_BRANCH)
        return CAT(DCI_SRC_BRANCH, sv);
#else
        return {};
#endif
    }

    /////////0/////////1/////////2/////////3/////////4/////////5/////////6/////////7
    std::string_view srcRevision()
    {
#if defined(DCI_SRC_REVISION)
        return CAT(DCI_SRC_REVISION, sv);
#else
        return {};
#endif
    }

    /////////0/////////1/////////2/////////3/////////4/////////5/////////6/////////7
    std::uint64_t srcMoment()
    {
#if defined(DCI_SRC_MOMENT)
        return DCI_SRC_MOMENT;
#else
        return {};
#endif
    }

    /////////0/////////1/////////2/////////3/////////4/////////5/////////6/////////7
    std::string_view platformOs()
    {
#if defined(DCI_PLATFORM_OS)
        return CAT(DCI_PLATFORM_OS, sv);
#else
        return {};
#endif
    }

    /////////0/////////1/////////2/////////3/////////4/////////5/////////6/////////7
    std::string_view platformArch()
    {
#if defined(DCI_PLATFORM_ARCH)
        return CAT(DCI_PLATFORM_ARCH, sv);
#else
        return {};
#endif
    }

    /////////0/////////1/////////2/////////3/////////4/////////5/////////6/////////7
    std::string_view compiler()
    {
#if defined(DCI_COMPILER)
        return CAT(DCI_COMPILER, sv);
#else
        return {};
#endif
    }

    /////////0/////////1/////////2/////////3/////////4/////////5/////////6/////////7
    std::string_view compilerVersion()
    {
#if defined(DCI_COMPILER_VERSION)
        return CAT(DCI_COMPILER_VERSION, sv);
#else
        return {};
#endif
    }

    /////////0/////////1/////////2/////////3/////////4/////////5/////////6/////////7
    std::string_view compilerOptimization()
    {
#if defined(DCI_COMPILER_OPTIMIZATION)
        return CAT(DCI_COMPILER_OPTIMIZATION, sv);
#else
        return {};
#endif
    }

    /////////0/////////1/////////2/////////3/////////4/////////5/////////6/////////7
    std::string_view provider()
    {
#if defined(DCI_PROVIDER)
        return CAT(DCI_PROVIDER, sv);
#else
        return {};
#endif
    }

    /////////0/////////1/////////2/////////3/////////4/////////5/////////6/////////7
    std::string_view API_DCI_INTEGRATION version()
    {
        static std::string res = version(srcBranch(), srcRevision(), srcMoment());
        return res;
    }

    /////////0/////////1/////////2/////////3/////////4/////////5/////////6/////////7
    std::string API_DCI_INTEGRATION version(std::string_view srcBranch, std::string_view srcRevision, std::uint64_t srcMoment)
    {
        time_t moment = srcMoment;
        std::string momentStr;
        momentStr.resize(64);
        momentStr.resize(strftime(momentStr.data(), momentStr.size(), "%Y-%m-%d", std::gmtime(&moment)));

        return
                momentStr + "-" +
                std::string{srcBranch} + "-" +
                std::string(srcRevision.data(), std::min(srcRevision.size(), std::size_t{7}));
    }
}
