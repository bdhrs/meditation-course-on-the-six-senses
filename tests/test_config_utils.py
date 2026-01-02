import os
import configparser
import pytest
from maintenance.config_utils import get_config_value, get_api_key

@pytest.fixture
def temp_config_file(tmp_path):
    config_path = tmp_path / "config.ini"
    config = configparser.ConfigParser()
    config['DEFAULT'] = {'API_KEY': 'test_key'}
    config['api'] = {'openrouter': 'test_key_api'}
    config['OPENROUTER'] = {'MODEL': 'test_model'}
    with open(config_path, 'w') as configfile:
        config.write(configfile)
    return config_path

def test_get_config_value_success(temp_config_file):
    # We need to point get_config_value to our temp file
    # This implies config_utils should support a custom path or we mock the path
    val = get_config_value('OPENROUTER', 'MODEL', config_path=temp_config_file)
    assert val == 'test_model'

def test_get_api_key_success(temp_config_file):
    # Assuming get_api_key is a convenience wrapper for OpenRouter API key
    key = get_api_key(config_path=temp_config_file)
    assert key == 'test_key_api'

def test_get_config_value_missing_section(temp_config_file):
    with pytest.raises(KeyError):
        get_config_value('NON_EXISTENT', 'KEY', config_path=temp_config_file)

def test_get_config_value_missing_key(temp_config_file):
    with pytest.raises(KeyError):
        get_config_value('OPENROUTER', 'MISSING', config_path=temp_config_file)

def test_get_config_value_missing_file():
    with pytest.raises(FileNotFoundError):
        get_config_value('OPENROUTER', 'MODEL', config_path="non_existent.ini")
