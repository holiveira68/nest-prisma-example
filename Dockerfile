# ---------------------------------------------------------------------------
FROM node:24-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# ---------------------------------------------------------------------------
FROM build AS migrator
ENV NODE_ENV=production \
    NPM_CONFIG_UPDATE_NOTIFIER=false
CMD ["npx", "prisma", "migrate", "deploy"]

# ---------------------------------------------------------------------------
FROM node:24-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production
COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=build /app/dist ./dist
#COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
EXPOSE 3000
CMD ["node", "dist/main.js"]

FROM build AS migrator
LABEL org.opencontainers.image.source=https://github.com/holiveira68/nest-prisma-example
LABEL org.opencontainers.image.description="Migrations e seed do Prisma (nest-prisma-example)"

FROM node:24-alpine AS runtime
LABEL org.opencontainers.image.source=https://github.com/holiveira68/nest-prisma-example
LABEL org.opencontainers.image.description="API NestJS + Prisma (nest-prisma-example)"
