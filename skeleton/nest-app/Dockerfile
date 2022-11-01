FROM node:latest as builder

WORKDIR /app

COPY . .

RUN npm i && npm i -g @nestjs/cli && npm run build

FROM node:current-alpine as production

WORKDIR /app

COPY package*.json ./

RUN npm install --only=production

COPY --from=builder /app/dist ./dist

CMD ["npm","run","start:prod"]
