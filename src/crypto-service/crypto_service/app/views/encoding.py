"""Application implementation - error response."""
from typing import Dict, Any, List
from pydantic import BaseModel


class EncodingResponse(BaseModel):
    """Define base encoding model for the response.

    Attributes:
        encoding (List[str]): encoding vector.

    Raises:
        pydantic.error_wrappers.ValidationError: If any of provided attribute
            doesn't pass type validation.

    """

    encoding: List[str]
    root: str

    class Config:
        """Config sub-class needed to extend/override the generated JSON schema.

        More details can be found in pydantic documentation:
        https://pydantic-docs.helpmanual.io/usage/schema/#schema-customization

        """

        @staticmethod
        def schema_extra(schema: Dict[str, Any]) -> None:
            """Post-process the generated schema.

            Method can have one or two positional arguments. The first will be
            the schema dictionary. The second, if accepted, will be the model
            class. The callable is expected to mutate the schema dictionary
            in-place; the return value is not used.

            Args:
                schema (typing.Dict[str, typing.Any]): The schema dictionary.

            """
            # Override schema description, by default is taken from docstring.
            schema["description"] = "Error model."
            # Add status to schema properties.
            schema["properties"].update(
                {"status": {"title": "Status", "type": "string"}}
            )
            schema["required"].append("status")


class RootHashResponse(BaseModel):
    """Define base root hash model for the response.

    Attributes:
        root (str): root hash.

    Raises:
        pydantic.error_wrappers.ValidationError: If any of provided attribute
            doesn't pass type validation.

    """

    root: str

    class Config:
        """Config sub-class needed to extend/override the generated JSON schema.

        More details can be found in pydantic documentation:
        https://pydantic-docs.helpmanual.io/usage/schema/#schema-customization

        """

        @staticmethod
        def schema_extra(schema: Dict[str, Any]) -> None:
            """Post-process the generated schema.

            Method can have one or two positional arguments. The first will be
            the schema dictionary. The second, if accepted, will be the model
            class. The callable is expected to mutate the schema dictionary
            in-place; the return value is not used.

            Args:
                schema (typing.Dict[str, typing.Any]): The schema dictionary.

            """
            # Override schema description, by default is taken from docstring.
            schema["description"] = "Error model."
            # Add status to schema properties.
            schema["properties"].update(
                {"status": {"title": "Status", "type": "string"}}
            )
            schema["required"].append("status")


class ComputationResultResponse(BaseModel):
    """Define base computation result model for the response.

    Attributes:
        encoding (List[str]): encoding vector.
        result: int

    Raises:
        pydantic.error_wrappers.ValidationError: If any of provided attribute
            doesn't pass type validation.

    """

    encoding: List[str]
    decoded: List[str]
    result: int

    class Config:
        """Config sub-class needed to extend/override the generated JSON schema.

        More details can be found in pydantic documentation:
        https://pydantic-docs.helpmanual.io/usage/schema/#schema-customization

        """

        @staticmethod
        def schema_extra(schema: Dict[str, Any]) -> None:
            """Post-process the generated schema.

            Method can have one or two positional arguments. The first will be
            the schema dictionary. The second, if accepted, will be the model
            class. The callable is expected to mutate the schema dictionary
            in-place; the return value is not used.

            Args:
                schema (typing.Dict[str, typing.Any]): The schema dictionary.

            """
            # Override schema description, by default is taken from docstring.
            schema["description"] = "Error model."
            # Add status to schema properties.
            schema["properties"].update(
                {"status": {"title": "Status", "type": "string"}}
            )
            schema["required"].append("status")
