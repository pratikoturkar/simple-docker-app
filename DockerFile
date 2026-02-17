# ---- Build Stage ----
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install --only=production
COPY . .

# ---- Runtime Stage ----
FROM node:18-alpine

WORKDIR /app
COPY --from=builder /app /app

ARG VERSION=dev
ENV VERSION=$VERSION

EXPOSE 8080

CMD ["node", "server.js"]
