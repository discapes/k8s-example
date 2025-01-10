Development

```bash
poetry install
poetry shell
fastapi dev chat # dev
fastapi run chat # prod
```

Building and running
```bash
docker build . -t chat
docker run -d --name redis -p 6379:6379 redis
docker run -p8000:80 -eREDIS_HOST=host.docker.internal -it --rm chat
```
