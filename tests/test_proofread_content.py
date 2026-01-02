import pytest
from unittest.mock import patch, MagicMock
from maintenance.proofread_content import Proofreader

def test_proofreader_initialization_missing_api_key():
    # Mock get_api_key to raise KeyError
    with patch('maintenance.proofread_content.get_api_key', side_effect=KeyError):
        with pytest.raises(KeyError):
            Proofreader()

def test_proofreader_initialization_success():
    with patch('maintenance.proofread_content.get_api_key', return_value='fake_key'):
        pr = Proofreader()
        assert pr.api_key == 'fake_key'
        assert pr.model == "xiaomi/mimo-v2-flash:free"

@patch('maintenance.proofread_content.OpenRouter')
def test_proofread_text_call(mock_openrouter):
    # Mock the client and the chat.send response
    mock_client = MagicMock()
    mock_openrouter.return_value.__enter__.return_value = mock_client
    
    mock_response = MagicMock()
    mock_response.choices = [MagicMock()]
    mock_response.choices[0].message.content = "Suggested text"
    mock_client.chat.send.return_value = mock_response
    
    with patch('maintenance.proofread_content.get_api_key', return_value='fake_key'):
        pr = Proofreader()
        result = pr.call_llm("Original text")
        
        assert result == "Suggested text"
        mock_client.chat.send.assert_called_once()

def test_extract_proofreadable_segments():
    content = (
        "Intro text.\n\n"
        "> Pāḷi quote block (should be ignored)\n"
        "> more quote\n\n"
        "Prose after quote.\n"
        "%% Transcript segment %% \n"
        "More prose."
    )
    with patch('maintenance.proofread_content.get_api_key', return_value='fake_key'):
        pr = Proofreader()
        segments = pr.extract_segments(content)
        
        # Combined segments are fine
        all_text = "\n".join(segments)
        assert "Intro text." in all_text
        assert "Prose after quote." in all_text
        assert "Transcript segment" in all_text
        assert "Pāḷi quote block" not in all_text

def test_extract_segments_complex():
    content = """# Header 1

This is prose with *italics* and **bold**.

> This is a Pāḷi blockquote.
> It should be ignored.
> even if it's long.

%%
This is a transcript.
It spans multiple lines.
%%

More prose here.

```python
# Code block should also be ignored
print("hello")
```

Final prose.
"""
    with patch('maintenance.proofread_content.get_api_key', return_value='fake_key'):
        pr = Proofreader()
        segments = pr.extract_segments(content)
        
        # We expect Header 1, prose, transcript, and final prose.
        # We expect blockquote and code block to be ignored.
        
        all_text = "\n".join(segments)
        assert "# Header 1" in segments
        assert "This is prose with *italics* and **bold**." in all_text
        assert "This is a transcript." in all_text
        assert "It spans multiple lines." in all_text
        assert "Final prose." in all_text
        
        # Ignored parts
        assert "This is a Pāḷi blockquote." not in all_text
        assert "print(\"hello\")" not in all_text

@patch('time.sleep', return_value=None)
@patch('maintenance.proofread_content.OpenRouter')
def test_proofreader_delay(mock_openrouter, mock_sleep):
    mock_client = MagicMock()
    mock_openrouter.return_value.__enter__.return_value = mock_client
    mock_client.chat.send.return_value = MagicMock()
    
    with patch('maintenance.proofread_content.get_api_key', return_value='fake_key'):
        pr = Proofreader(delay=2.0)
        pr.call_llm("text")
        mock_sleep.assert_called_with(2.0)

@patch('maintenance.proofread_content.OpenRouter')
def test_call_llm_error_handling(mock_openrouter):
    mock_client = MagicMock()
    mock_openrouter.return_value.__enter__.return_value = mock_client
    mock_client.chat.send.side_effect = Exception("API Error")
    
    with patch('maintenance.proofread_content.get_api_key', return_value='fake_key'):
        pr = Proofreader()
        result = pr.call_llm("text")
        assert result == "NO_ERRORS"
