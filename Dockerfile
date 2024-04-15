ARG NGINX_VERSION=1.24.0

FROM nginx:$NGINX_VERSION-alpine as build

ARG NGINX_VERSION=1.24.0

RUN apk --update --no-cache add \
        gcc \
        make \
        libc-dev \
        g++ \
        openssl-dev \
        linux-headers \
        pcre-dev \
        zlib-dev \
        libtool \
        automake \
        autoconf \
        git

RUN cd /opt \
    && git clone --depth 1 --single-branch https://github.com/nginx-modules/ngx_cache_purge.git \
    && wget -O - http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | tar zxfv - \
    && mv /opt/nginx-$NGINX_VERSION /opt/nginx \
    && cd /opt/nginx \
    && ./configure --with-compat --add-dynamic-module=/opt/ngx_cache_purge \
    && make modules

FROM nginx:$NGINX_VERSION-alpine

RUN apk --update --no-cache add \
        wget

COPY --from=0 /opt/nginx/objs/ngx_http_cache_purge_module.so /usr/lib/nginx/modules

RUN chmod -R 644 /usr/lib/nginx/modules/ngx_http_cache_purge_module.so \
    && sed -i '1iload_module \/usr\/lib\/nginx\/modules\/ngx_http_cache_purge_module.so;' /etc/nginx/nginx.conf
