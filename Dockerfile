FROM alpine:3.12 AS builder

ARG BUILD_VERSION=1.16.40.02

ENV VERSION=$BUILD_VERSION 

WORKDIR /builder

#Dependencies
RUN apk add curl unzip grep &&\
#Download
    if [ "$VERSION" = "latest" ] ; then \
        LATEST_VERSION=$( \
            curl --silent  https://www.minecraft.net/en-us/download/server/bedrock | \
            grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' | \
            grep -oP '[\d\.]+(?=\.)') && \
        export VERSION=$LATEST_VERSION && \
        echo "Setting VERSION to $LATEST_VERSION" ; \
    else echo "Using VERSION of $VERSION"; \
    fi && \
    curl https://minecraft.azureedge.net/bin-linux/bedrock-server-${VERSION}.zip --output bedrock_server.zip && \
    unzip -q bedrock_server.zip -d bedrock_server && \
    echo ${VERSION} > bedrock_server/version.txt
    
############################################################################################

FROM ubuntu:18.04

WORKDIR /server

#Dependencies and server user
RUN useradd -u 1000 server

COPY --from=builder --chown=server /builder/bedrock_server  ./

ENV LD_LIBRARY_PATH=.

USER server

EXPOSE 19132/udp

CMD ./bedrock_server