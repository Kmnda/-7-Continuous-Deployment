import pytest
from app import app as flask_app

@pytest.fixture
def app():
    yield flask_app

@pytest.fixture
def client(app):
    return app.test_client()

def test_hello(client):
    """Test the hello endpoint."""
    res = client.get('/')
    assert res.status_code == 200
    assert b"Hello from the Staging Environment!" in res.data