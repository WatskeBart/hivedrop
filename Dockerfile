FROM nginxinc/nginx-unprivileged:latest

COPY index.html /usr/share/nginx/html/
COPY ./honey/ /usr/share/nginx/html/honey/
COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
