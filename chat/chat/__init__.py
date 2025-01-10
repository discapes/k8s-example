import redis
import os
from typing import Union
from fastapi import FastAPI, HTTPException

redis_host = os.environ["REDIS_HOST"] if "REDIS_HOST" in os.environ else "localhost"
app = FastAPI()
r = redis.Redis(host=redis_host, port=6379, db=0)

@app.get("/")
def read_root():
    try: 
        r.set('foo', 'bar')
        result = r.get('foo')
        print(result)
        return result
    except Exception as e:
        raise HTTPException(status_code=404, detail=str(e))


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}

