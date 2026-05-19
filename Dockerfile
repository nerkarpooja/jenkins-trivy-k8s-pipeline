FROM node:22-alpine3.21

WORKDIR /app

COPY app.js .

EXPOSE 3000

CMD ["node", "app.js"]