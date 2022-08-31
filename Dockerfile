FROM golang:1.19 as builder

ARG GOPROXY
ENV GOOS=linux \
    GOARCH=amd64 \
    CGO_ENABLED=0

WORKDIR /go/src/clickhouse-bulk

# Cache dependencies
ADD go.* ./
RUN go mod download

# Build
ADD . ./
RUN go build -v

FROM alpine:latest
RUN apk add ca-certificates
WORKDIR /app
RUN mkdir /app/dumps
COPY --from=builder /go/src/clickhouse-bulk/config.sample.json .
COPY --from=builder /go/src/clickhouse-bulk/clickhouse-bulk .
EXPOSE 8123
ENTRYPOINT ["./clickhouse-bulk", "-config=config.sample.json"]
