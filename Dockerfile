ARG NGINX_VERSION=latest
FROM nginx:latest

RUN apt-get update && apt-get install -y certbot && mkdir /acme-challenge

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]