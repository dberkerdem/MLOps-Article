import yaml
from os import path
from typing import Dict

__all__ = ["load_config"]


def load_config(config_file: str) -> Dict:
    """
    Load a configuration file in YAML format.

    Args:
        config_file (str): The absolute path of the configuration file.

    Returns:
        Dict: A dictionary containing the configuration settings.

    Raises:
        FileNotFoundError: If the specified configuration file does not exist.
        yaml.YAMLError: If there is an error in parsing the YAML file.
    """

    if not path.exists(config_file):
        raise FileNotFoundError(f'{config_file} config file does not exist')

    with open(config_file, 'r') as stream:
        try:
            config = yaml.safe_load(stream)
        except yaml.YAMLError as exception:
            print(exception)
            raise

    return config
