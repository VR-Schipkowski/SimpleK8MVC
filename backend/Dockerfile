# Build stage
FROM node:16.13.0-alpine AS build

# Arbeitsverzeichnis im Container
WORKDIR /usr/src/app

# Kopiere die package.json und package-lock.json
COPY package*.json ./

# Installiere die Abhängigkeiten
RUN npm install

# Kopiere den gesamten Quellcode
COPY . .

# Kompiliere TypeScript zu JavaScript
RUN npx tsc

# Production stage
FROM node:16.13.0-alpine

# Arbeitsverzeichnis im Container
ENTRYPOINT [ "node", "dist/backend.js" ]

# Kopiere nur die notwendigen Dateien aus dem Build-Container
COPY --from=build /usr/src/app/dist ./dist
COPY --from=build /usr/src/app/package*.json ./

# Installiere nur die Produktionsabhängigkeiten
RUN npm install --only=production

# Exponiere den Port, auf dem das Backend läuft
EXPOSE 8080

# Starte den Server
CMD [ "node", "dist/backend.js" ]
