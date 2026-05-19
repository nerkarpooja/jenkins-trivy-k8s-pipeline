FROM node:22-alpine3.21

# Update openssl to fix CRITICAL vulnerabilities
RUN apk update && apk upgrade --no-cache

WORKDIR /app

COPY app.js .

EXPOSE 3000

CMD ["node", "app.js"]