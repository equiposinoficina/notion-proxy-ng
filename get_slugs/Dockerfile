FROM node:12-alpine

RUN mkdir -p /notion-proxy/node_modules && chown node:node /notion-proxy && chown -R node:node /notion-proxy/*

WORKDIR /notion-proxy

COPY package*.json ./

USER node

RUN npm install

COPY --chown=node:node . .

CMD [ "node", "get_slugs.js" ]