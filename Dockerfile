# Build stage
FROM golang:1.24.5-alpine AS builder

WORKDIR /app

COPY go.mod ./

# Download Go modules and dependencies
RUN go mod download

# Copy all the Go files ending with .go extension
COPY *.go ./

RUN go build -o simpleWebServer

# Final stage
FROM scratch

LABEL org.opencontainers.image.description="A simple HTTP server written in Go with health check and main endpoints"

COPY --from=builder /app/simpleWebServer /

CMD ["/simpleWebServer"]
