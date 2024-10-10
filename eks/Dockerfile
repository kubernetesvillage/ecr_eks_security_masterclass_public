# Use an official Ubuntu as a base image
FROM ubuntu:latest

# Install basic utilities (optional)
RUN apt-get update && apt-get install -y curl

# Set a simple environment variable
ENV MESSAGE="Hello from Docker"

# Define the command to run when the container starts
CMD ["sh", "-c", "echo Docker image is ready for AWS ECR scanning; while true; do echo Pod is sleeping...; sleep 60; done"]
