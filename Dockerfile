# -----------------------------------------------------------------------------
# Compile the application
# -----------------------------------------------------------------------------
FROM golang:1.18-alpine AS builder

# This is optional, but recommended to install dependencies.
# RUN apk add --no-cache git

# Move to working directory (/build).
WORKDIR /build

# Copy and download dependency using go mod.
COPY go.mod go.sum ./
RUN go mod download

# Copy the code into the container.
COPY . .

# Set necessary environment variables needed for our image and build the API server.
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -ldflags="-s -w" -o apigo .

# -----------------------------------------------------------------------------
# Start fresh from a smaller image
# -----------------------------------------------------------------------------
FROM scratch as runner
LABEL maintainer="Aris Ripandi <aris@duck.com> (https://ripandis.com)"

ARG JWT_SECRET_KEY
ENV JWT_SECRET_KEY $JWT_SECRET_KEY

# Copy binary and config files from builder to scratch container.
COPY --from=builder /build/apigo /apigo
COPY --from=builder /build/.env /.env

# EXPOSE 3030

# Command to run when starting the container.
ENTRYPOINT ["/apigo"]
