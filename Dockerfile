# Start with a lightweight base image
FROM golang:1.21 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the application code
COPY . .

# Install Air for live reloading
RUN go install github.com/cosmtrek/air@latest

# Build the application
RUN go build -o main .

# Final production image
FROM golang:1.21

# Set the working directory
WORKDIR /app

# Copy the built binary from the builder
COPY --from=builder /app/main /app/main
COPY --from=builder /go/bin/air /go/bin/air
COPY . /app

# Expose the application port
EXPOSE 8080

# Run the application with Air
CMD ["air"]
