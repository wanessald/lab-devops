from fastapi import FastAPI
from pydantic import BaseModel, Field
from typing import List

app = FastAPI(
    title="lab-devops API",
    description="Minimal task API for infrastructure learning",
    version="1.0.0"
)

# In-memory storage
tasks = [
    {"id": 1, "title": "Learn Terraform", "done": True},
    {"id": 2, "title": "Provision Azure VM", "done": True},
    {"id": 3, "title": "Deploy Docker container", "done": True},
    {"id": 4, "title": "Build FastAPI application", "done": False},
]

class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=120)
    done: bool = False

class TaskResponse(TaskCreate):
    id: int

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/api/tasks", response_model=List[TaskResponse])
def get_tasks():
    return tasks

@app.post("/api/tasks", response_model=TaskResponse, status_code=201)
def create_task(task: TaskCreate):
    new_task = {
        "id": len(tasks) + 1,
        "title": task.title,
        "done": task.done
    }
    tasks.append(new_task)
    return new_task
