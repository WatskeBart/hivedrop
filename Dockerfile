FROM nginxinc/nginx-unprivileged:1.28-alpine3.21 as builder

USER root

RUN apk add --no-cache \
    gcc libc-dev make openssl-dev pcre2-dev zlib-dev \
    linux-headers curl xz

RUN NGINX_VERSION=$(nginx -v 2>&1 | grep -o '[0-9.]*') && \
    curl -fSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz && \
    curl -fSL https://github.com/aperezdc/ngx-fancyindex/releases/download/v0.5.2/ngx-fancyindex-0.5.2.tar.xz -o fancyindex.tar.xz && \
    tar -zxf nginx.tar.gz && \
    tar -xf fancyindex.tar.xz && \
    cd nginx-* && \
    ./configure --add-dynamic-module=../ngx-fancyindex-* --with-compat && \
    make modules

FROM nginxinc/nginx-unprivileged:1.28-alpine3.21

USER root

COPY --from=builder /nginx-*/objs/ngx_http_fancyindex_module.so /usr/lib/nginx/modules/

USER nginx

COPY index.html /usr/share/nginx/html/
COPY ./honey/ /usr/share/nginx/html/honey/
COPY ./fancyindex/ /usr/share/nginx/html/fancyindex/
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf
COPY --chmod=755 ./scripts/99_nginx_address.sh /docker-entrypoint.d/

LABEL org.opencontainers.image.title "HiveDrop"
LABEL org.opencontainers.image.description "HiveDrop serves, periodically downloaded, files via a (rootless) Nginx web server."
LABEL org.opencontainers.image.authors "WatskeBart"
LABEL org.opencontainers.image.source "https://github.com/WatskeBart/hivedrop/"

EXPOSE 8080/tcp

CMD ["nginx", "-g", "daemon off;"]