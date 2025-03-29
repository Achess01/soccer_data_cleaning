class BaseModel:

    @classmethod
    def from_json(cls, json_data: dict):
        """
        Converts JSON data to a class instance.
        """
        raise NotImplementedError(
            "Subclasses must implement from_json method.")
