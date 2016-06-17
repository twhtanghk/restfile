FROM node

WORKDIR /root
RUN	apt-get update && \
	apt-get install -y libkrb5-dev && \
	apt-get clean && \
	npm install
EXPOSE 1337

ENTRYPOINT ./entrypoint.sh
