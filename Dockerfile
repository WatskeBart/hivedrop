FROM nginxinc/nginx-unprivileged:1.26-alpine3.20-perl

USER root

RUN apk update && apk add nginx-mod-http-fancyindex

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