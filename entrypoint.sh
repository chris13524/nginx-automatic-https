#!/usr/bin/env bash

set -e

if [ -z "$HOST" ]; then
	echo "You need to specify the HOST environment variable."
	exit 1
fi

sed -ie "s|\$HOST|$HOST|g" /etc/nginx/conf.d/default.conf

function renew() {
	certbot renew --webroot --webroot-path "/acme-challenge"
}
function renewAndReload() {
	renew
	nginx -s reload
}

if [ -d "/etc/letsencrypt/live/$HOST" ]; then
	renew
else
	certbot certonly --agree-tos --email "$EMAIL" -d "$HOST" --standalone $FLAGS
fi

TLS_PROTO=""
if [ -z "$TLS" ]; then
	TLS_PROTO="TLSv1.2"
else
	TLS_PROTO="$TLS"
fi
sed -ie "s|\$TLS_PROTO|$TLS_PROTO|g" /etc/nginx/conf.d/default.conf

BODY=""

if [ "$HSTS" = true ]; then
	BODY="$BODY add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains; preload\" always;"
fi

if [ "$HSTS_NP" = true ]; then
	BODY="$BODY add_header Strict-Transport-Security \"max-age=31536000; includeSubDomains\" always;"
fi

if [ "$HSTS_NSD" = true ]; then
	BODY="$BODY add_header Strict-Transport-Security \"max-age=31536000\" always;"
fi

if [ "$HSTS_WEEK" = true ]; then
	BODY="$BODY add_header Strict-Transport-Security \"max-age=604800\" always;"
fi

if [ -n "$PROXY" ]; then
	BODY="$BODY location / { proxy_pass $PROXY; }"
fi

if [ -n "$CUSTOM" ]; then
	BODY="$BODY $CUSTOM"
fi

sed -ie "s|\$BODY|$BODY|g" /etc/nginx/conf.d/default.conf

function renewLoop() {
	while true; do
		sleep 86400
		renewAndReload
	done
}
renewLoop &

nginx -g "daemon off;"