import pytest
from ..cw_agent import CWAgent


class TestCWAgent:
    """
    Test class dedicated to the CloudWatch Agent
    """

    def test_one(self):
        x = "this"
        assert 'h' in x