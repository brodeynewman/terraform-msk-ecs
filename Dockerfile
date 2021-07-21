FROM ubuntu:latest

USER root
WORKDIR /tmp

RUN apt-get update
RUN apt-get -y install curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_14.x  | bash -
RUN apt-get -y install nodejs

COPY . .

RUN npm install

ENV NODE_ENV production

EXPOSE 3000

CMD ["npm", "start"]