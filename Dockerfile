# Multi-stage build for production-ready image
FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

FROM node:18-alpine

WORKDIR /app

# Install dumb-init for proper signal handling
# RUN apk add --no-cache dumb-init

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app . 

EXPOSE 8080
CMD ["node", "source_code/server.js"]
