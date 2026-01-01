from maintenance.audit_content import check_pali_formatting

def test_unformatted_pali_term_fails():
    content = "The Dukkha is profound."
    errors = check_pali_formatting(content)
    assert any("Dukkha" in e for e in errors), "Should detect unformatted 'Dukkha'"

def test_formatted_pali_term_passes():
    content = "The *Dukkha* is profound."
    errors = check_pali_formatting(content)
    assert len(errors) == 0, "Should pass formatted '*Dukkha*'"

def test_link_pali_term_passes():
    content = "The [[Dukkha]] is profound."
    errors = check_pali_formatting(content)
    assert len(errors) == 0, "Should pass linked '[[Dukkha]]'"

def test_multiple_terms():
    content = "Both Dukkha and *Anicca* are truths."
    errors = check_pali_formatting(content)
    assert any("Dukkha" in e for e in errors)
    assert not any("Anicca" in e for e in errors)

def test_header_exclusion():
    content = "# Dukkha Talks"
    errors = check_pali_formatting(content)
    assert len(errors) == 0, "Should ignore headers"