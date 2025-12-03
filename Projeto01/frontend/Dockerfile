# Fase de build
FROM node:20 as build

WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# Fase de produção
FROM nginx:alpine

COPY --from=build /app/dist /usr/share/nginx/html

COPY env.template.js /usr/share/nginx/html/env.template.js
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x entrypoint.sh

EXPOSE 80

CMD ["/entrypoint.sh"]
