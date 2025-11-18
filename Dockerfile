# Stage 1: Dependency & Build Artifact Generation
FROM node:18-alpine AS build-stage

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev

COPY . .
RUN npm run build

# Stage 2: Production Runtime Execution
FROM node:18-alpine AS runtime-stage

WORKDIR /app

ENV NODE_ENV=production
EXPOSE 3000

COPY --from=build-stage /app/package*.json ./
RUN npm install --omit=dev

COPY --from=build-stage /app/.next ./.next
COPY --from=build-stage /app/public ./public
COPY --from=build-stage /app/next.config.ts ./next.config.ts

CMD ["npm", "start"]
