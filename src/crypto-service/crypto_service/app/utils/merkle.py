# This file is part of the Blockchain Data Trading Simulator
#    https://gitlab.com/MatthiasLohr/bdtsim
#
# Copyright 2020 Matthias Lohr <mail@mlohr.com>
#
# Adjusted in 2023 by Kevin Hertwig <kevin.hertwig@gmail.com> to use with Sha256 instead of Keccak256
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

import itertools
import math
from typing import Any, List, Tuple
from eth_abi.packed import encode_packed
import hashlib
from web3 import Web3


class MerkleTreeNode(object):
    def __init__(self, *children: "MerkleTreeNode") -> None:
        if len(children) > 2:
            raise ValueError("Cannot have more than two children")
        self._children = list(children)

    @property
    def children(self) -> List["MerkleTreeNode"]:
        return self._children

    @property
    def leaves(self) -> List["MerkleTreeLeaf"]:
        return list(itertools.chain.from_iterable([c.leaves for c in self.children]))

    @property
    def digest(self) -> bytes:
        keccak_inputs: List[Tuple[str, bytes]] = []
        for child in self.children:
            keccak_inputs.append(("bytes32", child.digest))
        _, args = zip(*keccak_inputs)
        return hashlib.sha256(
            encode_packed(
                ["bytes32", "bytes32"],
                [
                    Web3.toBytes(hexstr=args[0].hex()),
                    Web3.toBytes(hexstr=args[1].hex()),
                ],
            )
        ).digest()

    @property
    def digests_dfs(self) -> List[bytes]:
        return list(
            itertools.chain.from_iterable([c.digests_dfs for c in self.children])
        ) + [self.digest]

    @property
    def digests_pack(self) -> List[bytes]:
        return [
            digest
            for digest, level in sorted(
                self._digests_pack(0), key=lambda d: d[1], reverse=True
            )
        ]

    def _digests_pack(self, level: int) -> List[Tuple[bytes, int]]:
        return list(
            itertools.chain.from_iterable(
                [c._digests_pack(level + 1) for c in self.children]
            )
        ) + [(self.digest, level)]

    def has_indirect_child(self, node: "MerkleTreeNode") -> bool:
        if node in self.children:
            return True

        for child in self.children:
            if child.has_indirect_child(node):
                return True

        return False

    def get_proof(self, node: "MerkleTreeLeaf") -> List[bytes]:
        if self.children[0] == node:
            return [self.children[1].digest]
        elif self.children[1] == node:
            return [self.children[0].digest]

        if self.children[0].has_indirect_child(node):
            return [self.children[1].digest] + self.children[0].get_proof(node)
        elif self.children[1].has_indirect_child(node):
            return [self.children[0].digest] + self.children[1].get_proof(node)
        else:
            raise ValueError("Node is not part of this tree")

    @staticmethod
    def validate_proof(
        root_digest: bytes, node: "MerkleTreeNode", index: int, proof: List[bytes]
    ) -> bool:
        tmp_digest = node.digest
        for i in range(len(proof)):
            if (index & 1 << i) >> i == 1:
                tmp_digest = hashlib.sha256(
                    encode_packed(
                        ["bytes32", "bytes32"], [proof[len(proof) - i - 1], tmp_digest]
                    )
                ).digest()
            else:
                tmp_digest = hashlib.sha256(
                    encode_packed(
                        ["bytes32", "bytes32"], [tmp_digest, proof[len(proof) - i - 1]]
                    )
                ).digest()
        return tmp_digest == root_digest

    def __repr__(self) -> str:
        return "<%s.%s %s>" % (__name__, MerkleTreeNode.__name__, self.digest.hex())

    def __eq__(self, other: Any) -> bool:
        if isinstance(other, MerkleTreeNode):
            return self.digest == other.digest
        else:
            return NotImplemented

    def __ne__(self, other: Any) -> bool:
        return not self.__eq__(other)


class MerkleTreeLeaf(MerkleTreeNode):
    def __init__(self, data: bytes) -> None:
        super(MerkleTreeLeaf, self).__init__()
        if (len(data) % 32) != 0:
            raise ValueError("data length has to be a multiple of 32")
        self._data = data

    @property
    def digest(self) -> bytes:
        data_as_list = self.data_as_list()
        # noinspection PyCallByClass
        return hashlib.sha256(
            encode_packed(["bytes[%d]" % len(data_as_list)], [data_as_list])
        ).digest()

    @property
    def data(self) -> bytes:
        return self._data

    @data.setter
    def data(self, data: bytes) -> None:
        self._data = data

    def data_as_list(self, slice_size: int = 32) -> List[bytes]:
        return [
            self.data[i * slice_size : (i + 1) * slice_size]
            for i in range(int(len(self.data) / slice_size))
        ]

    @property
    def leaves(self) -> List["MerkleTreeLeaf"]:
        return [self]

    @property
    def digests_dfs(self) -> List[bytes]:
        return []

    @property
    def digests_pack(self) -> List[bytes]:
        return []

    def _digests_pack(self, level: int) -> List[Tuple[bytes, int]]:
        return []

    def __repr__(self) -> str:
        return "<%s.%s %s>" % (__name__, MerkleTreeLeaf.__name__, str(self.data))

    def __eq__(self, other: Any) -> bool:
        if isinstance(other, MerkleTreeLeaf):
            return self.data == other.data
        else:
            return False

    def __ne__(self, other: Any) -> bool:
        if isinstance(other, MerkleTreeLeaf):
            return not self.data == other.data
        else:
            return False


class MerkleTreeHashLeaf(MerkleTreeLeaf):
    @property
    def digest(self) -> bytes:
        return self.data


def from_leaves(leaves: List[MerkleTreeLeaf]) -> MerkleTreeNode:
    if len(leaves) == 0:
        raise ValueError("Cannot create tree from empty list")
    nodes: List[MerkleTreeNode] = list(leaves)
    while len(nodes) > 1:
        nodes = [MerkleTreeNode(*nodes[i : i + 2]) for i in range(0, len(nodes), 2)]

    return nodes[0]


def from_bytes(data: bytes, slices_count: int = 2) -> MerkleTreeNode:
    if slices_count < 2 or not math.log2(slices_count).is_integer():
        raise ValueError("slices_count must be >= 2 integer and power of 2")
    slice_len = math.ceil(len(data) / slices_count)
    return from_leaves(
        [
            MerkleTreeLeaf(data[slice_len * s : slice_len * (s + 1)])
            for s in range(slices_count)
        ]
    )


def from_list(items: List[bytes]) -> MerkleTreeNode:
    return from_leaves([MerkleTreeLeaf(item) for item in items])
