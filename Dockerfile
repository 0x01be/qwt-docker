FROM 0x01be/qwt:build as build

FROM alpine

RUN apk add --no-cache --virtual qwt-edge-runtime-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing  \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community  \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    qt5-qtbase \
    qt5-qtsvg \
    py3-qt5 \
    python3

COPY --from=build /opt/qwt/ /opt/qwt/

