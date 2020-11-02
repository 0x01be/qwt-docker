FROM alpine

RUN apk add --no-cache --virtual qwt-build-dependencies \
    git \
    subversion \
    build-base \
    cmake

RUN apk add --no-cache --virtual gnuradio-edge-build-dependencies \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing  \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community  \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    qt5-qtbase-dev \
    qt5-qtsvg-dev \
    py3-qt5 \
    python3-dev

ENV QWT_SVN_BRANCH 6.1
ENV QWT_VERSION 6.1.6

RUN svn checkout svn://svn.code.sf.net/p/qwt/code/branches/qwt-${QWT_SVN_BRANCH} /qwt

WORKDIR /qwt

RUN qmake-qt5 qwt.pro
RUN make install

RUN mkdir -p /opt/qwt/lib/ &&\
    mkdir -p /opt/qwt/include/ &&\
    cp -R /usr/local/qwt-${QWT_VERSION}-svn/lib/* /opt/qwt/lib/ &&\
    cp -R /usr/local/qwt-${QWT_VERSION}-svn/include/* /opt/qwt/include/

ENV PYQT_QWT_REVISION master
RUN git clone --depth 1 --branch ${PYQT_QWT_REVISION} https://github.com/GauiStori/PyQt-Qwt.git /pyqt-qwt

WORKDIR /pyqt-qwt

RUN sed -i.bak s/DocType\=\"dict-of-double-QString\"//g /pyqt-qwt/sip/qmap_convert.sip

# Needs to be sip4 (don't install with pip)
RUN apk add py3-sip-dev

RUN python3 configure.py \
    --destdir=/opt/qwt/ \
    --qwt-incdir=/opt/qwt/include/ \
    --qwt-libdir=/opt/qwt/lib/ \
    --qmake /usr/bin/qmake-qt5 \
    --verbose
RUN make install

