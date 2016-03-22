#!/usr/bin/env bash

##
# Copyright (c) 2008-2013 Marius Zwicker
# All rights reserved.
# 
# @LICENSE_HEADER_START:Apache@
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# http://www.mlba-team.de
# 
# @LICENSE_HEADER_END:Apache@
##

MZ_CMAKETOOLS_compiler=clang
MZ_CMAKETOOLS_generator=xcode
MZ_CMAKETOOLS_mode=debug

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/generator.sh $@