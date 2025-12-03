#!/bin/sh

# Gerar o env.js substituindo as variáveis reais
envsubst < /usr/share/nginx/html/env.template.js \
    > /usr/share/nginx/html/env.js

# Iniciar nginx
nginx -g "daemon off;"
