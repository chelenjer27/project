FROM alpine

RUN <<EOF 
    apk update 
    apk upgrade 
    apk add nginx
    ln -sf /dev/stdout /var/log/nginx/access.log
    ln -sf /dev/stderr /var/log/nginx/error.log
    echo '<h1>May the force come with you</h1>' > /var/www/index.html
EOF

COPY ./default.conf /etc/nginx/http.d/default.conf

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
