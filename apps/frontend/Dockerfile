FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
COPY apps/frontend/package.json apps/frontend/
RUN npm install
COPY . .
ENV NEXT_TELEMETRY_DISABLED 1
RUN npm run build --workspace=apps/frontend

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED 1
COPY --from=builder /app/apps/frontend/public ./public
COPY --from=builder /app/apps/frontend/.next/standalone ./
COPY --from=builder /app/apps/frontend/.next/static ./.next/static

EXPOSE 3000
CMD ["node", "server.js"]
