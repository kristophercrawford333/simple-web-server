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

COPY --from=builder /app/simpleWebServer /

# Expose service ports
EXPOSE 80
EXPOSE 8000

CMD ["/simpleWebServer"]

