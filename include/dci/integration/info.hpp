/* This file is part of the the dci project. Copyright (C) 2013-2021 vopl, shtoba.
   This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public
   License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
   of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
   You should have received a copy of the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. */

#pragma once

#include "api.hpp"
#include <string_view>
#include <string>

namespace dci::integration::info
{
    std::string_view API_DCI_INTEGRATION srcBranch();
    std::string_view API_DCI_INTEGRATION srcRevision();
    std::uint64_t    API_DCI_INTEGRATION srcMoment();
    std::string_view API_DCI_INTEGRATION platformOs();
    std::string_view API_DCI_INTEGRATION platformArch();
    std::string_view API_DCI_INTEGRATION compiler();
    std::string_view API_DCI_INTEGRATION compilerVersion();
    std::string_view API_DCI_INTEGRATION compilerOptimization();
    std::string_view API_DCI_INTEGRATION provider();

    std::string_view API_DCI_INTEGRATION version();
    std::string      API_DCI_INTEGRATION version(std::string_view srcBranch, std::string_view srcRevision, std::uint64_t srcMoment);
}
