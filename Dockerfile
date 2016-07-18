FROM	node

WORKDIR	/usr/src/app
ADD	https://github.com/twhtanghk/restfile/archive/master.tar.gz /tmp
RUN	tar --strip-components=1 -xzf /tmp/master.tar.gz && \
	rm /tmp/master.tar.gz && \
	apt-get update && \
	apt-get install -y libkrb5-dev && \
	apt-get clean && \
	npm install && \
	node_modules/.bin/bower install --allow-root
EXPOSE	1337

ENTRYPOINT ./entrypoint.sh
