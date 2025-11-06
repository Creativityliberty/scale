# Build stage
FROM node:20-slim AS builder
WORKDIR /app
COPY package.json package-lock.json* yarn.lock* pnpm-lock.yaml* ./
RUN if [ -f package-lock.json ]; then npm ci;     elif [ -f yarn.lock ]; then yarn install --frozen-lockfile;     elif [ -f pnpm-lock.yaml ]; then corepack enable && pnpm i --frozen-lockfile;     else npm i; fi
COPY . .
RUN npm run build

# Serve static with nginx
FROM nginx:1.27-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
