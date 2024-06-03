# Stage 1: Build the frontend
FROM node:14 as frontend-builder
WORKDIR /usr/src/app
COPY apps/frontend/package*.json ./
RUN npm install
COPY apps/frontend .
RUN npm run build

# Stage 2: Build the backend
FROM node:14 as backend-builder
WORKDIR /usr/src/app
COPY apps/backend/package*.json ./
RUN npm install
COPY apps/backend .
RUN npm run build

# Stage 3: Build the WebSocket server
FROM node:14 as ws-builder
WORKDIR /usr/src/app
COPY apps/ws/package*.json ./
RUN npm install
COPY apps/ws .
RUN npm run build

# Stage 4: Final image
FROM node:14
WORKDIR /usr/src/app
COPY --from=frontend-builder /usr/src/app/build ./frontend
COPY --from=backend-builder /usr/src/app/dist ./backend
COPY --from=ws-builder /usr/src/app/dist ./ws
COPY package*.json ./
RUN npm install --production


# Install PostgreSQL client library
RUN apt-get update && apt-get install -y postgresql-client

# Set environment variables for PostgreSQL connection
ENV DATABASE_URL=postgresql://chessdb_owner:icaWXO9nk3Rb@ep-solitary-sunset-a1wvsby2.ap-southeast-1.aws.neon.tech/chessdb?sslmode=require
ENV PGUSER=chessdb_owner
ENV PGPASSWORD=icaWXO9nk3Rb
ENV PGHOST=ep-solitary-sunset-a1wvsby2.ap-southeast-1.aws.neon.tech
ENV PGPORT=5432
ENV PGDATABASE=chessdb

EXPOSE 3000
CMD ["npm", "start"]