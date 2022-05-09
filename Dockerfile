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

ARG STAGE_STATUS=prod
ARG SERVER_PORT=3030
ARG SERVER_HOST=0.0.0.0
ARG SERVER_READ_TIMEOUT=60
ARG JWT_SECRET_KEY
ARG JWT_SECRET_KEY_EXPIRE_MINUTES_COUNT=15
ARG JWT_REFRESH_KEY
ARG JWT_REFRESH_KEY_EXPIRE_HOURS_COUNT=720
ARG DB_HOST
ARG DB_PORT
ARG DB_USER
ARG DB_PASSWORD
ARG DB_NAME
ARG DB_SSL_MODE
ARG DB_MAX_CONNECTIONS=100
ARG DB_MAX_IDLE_CONNECTIONS=10
ARG DB_MAX_LIFETIME_CONNECTIONS=2
ARG REDIS_HOST
ARG REDIS_PORT
ARG REDIS_PASSWORD
ARG REDIS_DB_NUMBER=0

ENV STAGE_STATUS $STAGE_STATUS
ENV SERVER_PORT $SERVER_PORT
ENV SERVER_HOST $SERVER_HOST
ENV SERVER_READ_TIMEOUT $SERVER_READ_TIMEOUT
ENV JWT_SECRET_KEY $JWT_SECRET_KEY
ENV JWT_SECRET_KEY_EXPIRE_MINUTES_COUNT $JWT_SECRET_KEY_EXPIRE_MINUTES_COUNT
ENV JWT_REFRESH_KEY $JWT_REFRESH_KEY
ENV JWT_REFRESH_KEY_EXPIRE_HOURS_COUNT $JWT_REFRESH_KEY_EXPIRE_HOURS_COUNT
ENV DB_HOST $DB_HOST
ENV DB_PORT $DB_PORT
ENV DB_USER $DB_USER
ENV DB_PASSWORD $DB_PASSWORD
ENV DB_NAME $DB_NAME
ENV DB_SSL_MODE $DB_SSL_MODE
ENV DB_MAX_CONNECTIONS $DB_MAX_CONNECTIONS
ENV DB_MAX_IDLE_CONNECTIONS $DB_MAX_IDLE_CONNECTIONS
ENV DB_MAX_LIFETIME_CONNECTIONS $DB_MAX_LIFETIME_CONNECTIONS
ENV REDIS_HOST $REDIS_HOST
ENV REDIS_PORT $REDIS_PORT
ENV REDIS_PASSWORD $REDIS_PASSWORD
ENV REDIS_DB_NUMBER $REDIS_DB_NUMBER

# Copy binary and config files from builder to scratch container.
COPY --from=builder /build/apigo /apigo
# COPY --from=builder /build/.env /.env

# EXPOSE 3030

# Command to run when starting the container.
ENTRYPOINT ["/apigo"]
