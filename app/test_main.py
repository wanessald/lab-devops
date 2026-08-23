import pytest
from fastapi.testclient import TestClient
from main import app, tasks

client = TestClient(app)

INITIAL_TASKS = [
    {"id": 1, "title": "Learn Terraform", "done": True},
    {"id": 2, "title": "Provision Azure VM", "done": True},
    {"id": 3, "title": "Deploy Docker container", "done": True},
    {"id": 4, "title": "Build FastAPI application", "done": False},
]

@pytest.fixture(autouse=True)
def reset_tasks():
    tasks.clear()
    tasks.extend(INITIAL_TASKS)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_get_tasks_returns_list():
    response = client.get("/api/tasks")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
    assert len(response.json()) == 4

def test_create_task_valid():
    response = client.post(
        "/api/tasks",
        json={"title": "Configure Jenkins", "done": False}
    )
    assert response.status_code == 201
    data = response.json()
    assert data["title"] == "Configure Jenkins"
    assert data["done"] == False
    assert "id" in data

def test_create_task_empty_title():
    response = client.post(
        "/api/tasks",
        json={"title": ""}
    )
    assert response.status_code == 422

def test_create_task_no_body():
    response = client.post("/api/tasks")
    assert response.status_code == 422

def test_docs_available():
    response = client.get("/docs")
    assert response.status_code == 200
