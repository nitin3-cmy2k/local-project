# === Stage 1: Build the frontend application ===
FROM node:18-alpine AS builder
WORKDIR /app

# Copy dependency files first to leverage Docker layer caching
COPY package*.json ./
RUN npm install

# Copy the rest of the frontend source code
COPY . .

# Build the production-ready static assets
RUN npm run build

# === Stage 2: Serve the application with Nginx ===
FROM nginx:1.25-alpine

# Copy the compiled static assets from the builder stage to Nginx web root
COPY --from=builder /app/build /usr/share/nginx/html

# Expose port 80 (matches containerPort in frontend-deployment.yaml)
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

