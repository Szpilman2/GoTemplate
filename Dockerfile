# Start with a modern Go base image
FROM golang:1.23.5 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum to download only dependencies
COPY go.mod go.sum ./

# Download Go module dependencies
RUN go mod download

# Copy the entire application code
COPY . .

# Install Air for live reloading
RUN go install github.com/air-verse/air@latest

# Build the Go application
RUN go build -buildvcs=false -o main .

# Final production image (also using Go 1.23.5 to avoid version mismatch)
FROM golang:1.23.5

# Set the working directory in the final image
WORKDIR /app

# Copy the built binary and Air from the builder stage
COPY --from=builder /app/main /app/main
COPY --from=builder /go/bin/air /go/bin/air

# Copy source code (for Air live reloading)
COPY . /app

# Expose the application port
EXPOSE 8080

# Run the application with Air (for live reloading)
CMD ["air"]
