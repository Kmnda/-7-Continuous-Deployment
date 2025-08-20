from app.app import app

def test_index_route():
    client = app.test_client()
    res = client.get("/")
    assert res.status_code == 200
    js = res.get_json()
    assert js.get("status") == "ok"
    assert "version" in js
