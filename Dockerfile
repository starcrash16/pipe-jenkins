FROM node:14-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --production

COPY . .

RUN npm run build

# Puerto interno siempre 3000; el mapeo externo lo hace Docker en el run
EXPOSE 3000

CMD ["npx", "serve", "-s", "build", "-l", "3000"]
