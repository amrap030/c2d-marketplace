# This file is part of the Blockchain Data Trading Simulator
#    https://gitlab.com/MatthiasLohr/bdtsim
#
# Copyright 2020 Matthias Lohr <mail@mlohr.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import random
from typing import Optional


def generate_bytes(
    length: int = 32, seed: Optional[int] = None, avoid: Optional[bytes] = None
) -> bytes:
    if seed is not None:
        random.seed(seed)
    tmp = avoid
    while tmp is None or tmp == avoid:
        tmp = bytes(bytearray(random.getrandbits(8) for _ in range(length)))
    return tmp
