ARG CRYSTAL_VERSION

FROM crystallang/crystal:$CRYSTAL_VERSION-alpine

ARG USER_ID
RUN adduser --disabled-password --gecos '' --uid $USER_ID u

WORKDIR /app

USER u
