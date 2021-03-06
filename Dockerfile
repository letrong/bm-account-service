# Create by Le Trong on 11/Feb/2019

# -------------------- Build --------------------
# Start from Alpine Linux image with the latest version of Golang
# Naming build stage as builder
FROM golang:alpine as builder

# Install Git for go get
RUN set -eux;\
  apk add --no-cache --virtual git &&\
  apk add --no-cache --virtual curl

# Set ENV
ENV GOPATH /go/
ENV GO_WORKDIR $GOPATH/src/accountservice

# Set WORKDIR to go source code directory
WORKDIR $GO_WORKDIR

# Add files to image
ADD . $GO_WORKDIR

# Fetch Golang Dependency and Build Binary
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh &&\
  dep ensure -add go.mongodb.org/mongo-driver/mongo &&\
  go install

# -------------------- Ready --------------------
# Start from a raw Alpine Linux image
FROM alpine:latest

# Set ENV
ENV PORT 80

# Install ca-certificates for ssl
RUN set -eux; \
  apk add --no-cache --virtual ca-certificates

# Set WORKDIR to go execute directory
WORKDIR /app

# Copy binary from builder stage into image
COPY --from=builder /go/bin/accountservice /app
COPY --from=builder /go/src/accountservice/config.yaml /app

EXPOSE $PORT
ENTRYPOINT ./accountservice
