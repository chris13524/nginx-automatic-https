# Nginx Automatic HTTPS

This is a Nginx container with Let's Encrypt installed. Provided a host variable, this container will automatically provision a Let's Encrypt certificate for it and keep it renewed.

The easiest way to use this is as a reverse proxy. But it does support custom configuration using the CUSTOM environment variable (you'd probally use this for static HTML files; see entrypoint.sh).

## Usage

Via a command:
```
docker run -it --rm \
    -e EMAIL=me@example.com \
    -e HOST=my.domain.com \
    -e PROXY=http://othercontainer:8080 \
    -v /path/in/host/:/etc/letsencrypt/ \
    -p "80:80" -p "443:443"
    chris13524/nginx-automatic-https
```

Via Docker Compose:
```
nginx-automatic-https:
  restart: always
  image: chris13524/nginx-automatic-https
  volumes:
    - /path/in/host/:/etc/letsencrypt/
  environment:
    - EMAIL=me@example.com
    - HOST=my.domain.com
    - PROXY=http://othercontainer:8080
  ports:
    - "80:80"
    - "443:443"
```