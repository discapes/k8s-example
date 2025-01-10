import redis
import os
from typing import Union
from fastapi import FastAPI, HTTPException

redis_host = os.environ["REDIS_HOST"] if "REDIS_HOST" in os.environ else "localhost"
redis_pass = os.environ["REDIS_PASS"] if "REDIS_PASS" in os.environ else None
vers = "v0.3"
app = FastAPI()
r = redis.Redis(host=redis_host, port=6379, password=redis_pass, db=0)


@app.get("/")
def read_root():
    try:
        r.set("foo", "baz")
        result = r.get("foo")
        print(result)
        return {"result": result, "version": vers}
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}
