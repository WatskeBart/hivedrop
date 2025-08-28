FROM nginxinc/nginx-unprivileged:latest

COPY index.html /usr/share/nginx/html/
COPY ./honey/ /usr/share/nginx/html/honey/
COPY default.conf /etc/nginx/conf.d/default.conf

LABEL org.opencontainers.image.title "HiveDrop"
LABEL org.opencontainers.image.description "HiveDrop serves periodically downloaded files from a container image."
LABEL org.opencontainers.image.authors "WatskeBart"

EXPOSE 8080/tcp

CMD ["nginx", "-g", "daemon off;"]
