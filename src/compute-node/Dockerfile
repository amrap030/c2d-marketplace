FROM zokrates/zokrates:0.8.4 as builder

FROM node:18.12.1-alpine3.16 AS node-build

# couchbase sdk requirements
RUN apk update && apk add yarn curl bash g++ make && rm -rf /var/cache/apk/*

# install node-prune (https://github.com/tj/node-prune)
RUN curl -sf https://gobinaries.com/tj/node-prune | sh

WORKDIR /app

COPY package*.json .
RUN yarn install

COPY . .
RUN yarn build

RUN npm prune --production

RUN node-prune /app/node_modules

FROM node:18.12.1-alpine3.16

RUN apk update && apk add gcompat

WORKDIR /app

COPY --from=node-build /app/dist ./dist
COPY --from=node-build /app/zokrates ./dist/zokrates
COPY --from=node-build /app/node_modules ./node_modules
COPY --from=builder /home/zokrates/.zokrates/bin/zokrates /app/zokrates
COPY --from=builder /home/zokrates/.zokrates/stdlib /app/stdlib/

RUN chmod +x /app/zokrates

EXPOSE 3000

CMD ["node", "./dist/server.js"]