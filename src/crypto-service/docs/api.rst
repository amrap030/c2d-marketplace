:tocdepth: 2
API
===

This part of the documentation lists the full API reference of all classes and functions.

WSGI
----

.. autoclass:: crypto_service.wsgi.ApplicationLoader
   :members:
   :show-inheritance:

Config
------

.. automodule:: crypto_service.config

.. autoclass:: crypto_service.config.application.Application
   :members:
   :show-inheritance:

.. autoclass:: crypto_service.config.redis.Redis
   :members:
   :show-inheritance:

.. automodule:: crypto_service.config.gunicorn

CLI
---

.. automodule:: crypto_service.cli

.. autofunction:: crypto_service.cli.cli.cli

.. autofunction:: crypto_service.cli.utils.validate_directory

.. autofunction:: crypto_service.cli.serve.serve

App
---

.. automodule:: crypto_service.app

.. autofunction:: crypto_service.app.asgi.on_startup

.. autofunction:: crypto_service.app.asgi.on_shutdown

.. autofunction:: crypto_service.app.asgi.get_application

.. automodule:: crypto_service.app.router

Controllers
~~~~~~~~~~~

.. automodule:: crypto_service.app.controllers

.. autofunction:: crypto_service.app.controllers.ready.readiness_check

Models
~~~~~~

.. automodule:: crypto_service.app.models

Views
~~~~~

.. automodule:: crypto_service.app.views

.. autoclass:: crypto_service.app.views.error.ErrorModel
   :members:
   :show-inheritance:

.. autoclass:: crypto_service.app.views.error.ErrorResponse
   :members:
   :show-inheritance:

Exceptions
~~~~~~~~~~

.. automodule:: crypto_service.app.exceptions

.. autoclass:: crypto_service.app.exceptions.http.HTTPException
   :members:
   :show-inheritance:

.. autofunction:: crypto_service.app.exceptions.http.http_exception_handler

Utils
~~~~~

.. automodule:: crypto_service.app.utils

.. autoclass:: crypto_service.app.utils.aiohttp_client.AiohttpClient
   :members:
   :show-inheritance:

.. autoclass:: crypto_service.app.utils.redis.RedisClient
   :members:
   :show-inheritance:
