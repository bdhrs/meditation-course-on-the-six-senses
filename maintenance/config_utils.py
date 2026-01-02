import configparser
import os
from pathlib import Path

DEFAULT_CONFIG_PATH = Path("config.ini")

def get_config_value(section, key, config_path=DEFAULT_CONFIG_PATH):
    """
    Reads a value from a config.ini file.
    """
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Config file not found: {config_path}")
    
    config = configparser.ConfigParser()
    config.read(config_path)
    
    if section not in config:
        raise KeyError(f"Section '{section}' not found in config.")
    
    if key not in config[section]:
        raise KeyError(f"Key '{key}' not found in section '{section}'.")
        
    return config[section][key]

def get_api_key(config_path=DEFAULT_CONFIG_PATH):
    """
    Convenience function to get the OpenRouter API key.
    """
    try:
        # Try specific section/key provided by user
        return get_config_value('api', 'openrouter', config_path=config_path)
    except KeyError:
        # Fallback to previously assumed locations just in case
        try:
            return get_config_value('OPENROUTER', 'API_KEY', config_path=config_path)
        except KeyError:
            return get_config_value('DEFAULT', 'API_KEY', config_path=config_path)
