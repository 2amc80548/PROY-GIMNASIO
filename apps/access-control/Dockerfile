# ---- builder ----
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
COPY tsconfig*.json nest-cli.json ./
RUN npm ci

COPY apps ./apps
COPY libs ./libs

# Compilamos específicamente access-control
RUN npx nest build access-control

# ---- runtime ----
FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY --from=builder /app/dist ./dist


CMD ["sh", "-c", "FILE=$(find dist -name main.js | grep access-control | head -n 1) && node $FILE"]
