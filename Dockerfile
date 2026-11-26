
# Etapa de testes
FROM node:24-alpine AS testes
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run test:unit && npm run test:integration

# Etapa de produção
FROM node:24-alpine AS producao
ENV NODE_ENV=production
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY --from=testes /app/public ./public
COPY --from=testes /app/src ./src
USER node
EXPOSE 3000
CMD ["node", "src/server.js"]
