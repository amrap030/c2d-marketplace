"""Crypto service for the C2D marketplace to handle merkle trees within fairswap"""
import logging

from crypto_service.wsgi import ApplicationLoader
from crypto_service.version import __version__

# initialize logging
log = logging.getLogger(__name__)
log.addHandler(logging.NullHandler())

__all__ = ("ApplicationLoader", "__version__")
