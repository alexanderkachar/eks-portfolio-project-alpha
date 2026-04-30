FROM node:24-alpine AS deps
WORKDIR /app
COPY src/package*.json ./
RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --omit=dev; fi

FROM node:24-alpine
WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=deps /app/node_modules ./node_modules
COPY src/ ./src/
COPY migrations/ ./migrations/
COPY src/package.json ./

RUN chown -R appuser:appgroup /app
USER appuser

EXPOSE 3000
CMD ["node", "src/index.js"]
