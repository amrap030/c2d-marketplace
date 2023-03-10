"""Application implementation - Encoding controller."""
import logging

from fastapi import APIRouter
from crypto_service.app.views import EncodingResponse, RootHashResponse
from crypto_service.app.utils import encoding, merkle, bytes as bytess
from pydantic import BaseModel
from typing import List


class ComputationResult(BaseModel):
    result: int
    nonce: int


router = APIRouter()
log = logging.getLogger(__name__)


@router.post(
    "/encoding",
    tags=["encoding"],
    response_model=EncodingResponse,
    summary="Creates encoding from merkle tree leaves.",
    status_code=200,
)
async def make_encoding(computation_result: ComputationResult) -> EncodingResponse:
    """Make encoding from merkle tree leaves.

    Returns:
        response (EncodingResponse): EncodingResponse model object instance.

    """
    log.info("Started POST /encoding")

    result = int.to_bytes(computation_result.result, 32, "big")
    nonce = int.to_bytes(computation_result.nonce, 32, "big")
    key = bytess.generate_bytes(32, 123)

    plain_merkle_tree = merkle.from_bytes(result + nonce)
    encrypted_merkle_tree = encoding.encode(plain_merkle_tree, key)

    leafs = [leaf.data.hex() for leaf in encrypted_merkle_tree.leaves]

    return EncodingResponse(encoding=leafs)


class Leafs(BaseModel):
    leafs: List[str]
    hash_leafs: List[str]


@router.post(
    "/root",
    tags=["encoding"],
    response_model=RootHashResponse,
    summary="Creates root hash from merkle tree leaves.",
    status_code=200,
)
async def make_encoding(leafs: Leafs) -> RootHashResponse:
    """Make root hash from merkle tree leaves.

    Returns:
        response (RootHashResponse): RootHashResponse model object instance.

    Raises:
        HTTPException: If applications has enabled Redis and can not connect
            to it. NOTE! This is the custom exception, not to be mistaken with
            FastAPI.HTTPException class.

    """
    log.info("Started POST /root")

    hex_leafs = [merkle.MerkleTreeLeaf(bytes.fromhex(leaf)) for leaf in leafs.leafs]
    hex_leafs.extend(
        [merkle.MerkleTreeHashLeaf(bytes.fromhex(leaf)) for leaf in leafs.hash_leafs]
    )

    merkle_tree = merkle.from_leaves(hex_leafs)

    return RootHashResponse(root=merkle_tree.digest.hex())
