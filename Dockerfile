# First build
FROM node:14-alpine3.12 AS build
ARG NPM_TOKEN
WORKDIR /build
COPY package*.json ./

# Final image
FROM node:14-alpine3.12
WORKDIR /app
COPY --from=build /build/node_modules ./node_modules
COPY ./src ./src
COPY ./package*.json ./
USER node
CMD ["npm", "start"]
