# Stage 1: Dependency & Build Artifact Generation
FROM node:18-alpine AS build-stage

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# Stage 2: Production Runtime Execution (Standalone Output)
FROM node:18-alpine AS runtime-stage

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

# Copy Next.js standalone output
COPY --from=build-stage /app/.next/standalone ./
COPY --from=build-stage /app/.next/static ./.next/static

# Only copy public if it exists (your project currently does not have it)
# COPY --from=build-stage /app/public ./public

CMD ["node", "server.js"]
