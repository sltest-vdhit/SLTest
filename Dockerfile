
# Start a new stage from scratch 
FROM ubuntu:24.04

# setup app as group and user
RUN groupadd -r app && useradd -r -s /bin/false -g app app

# Firewall setup
RUN apt-get update && \
    apt-get install -y ufw && \
    ufw allow 28000

# Security updates
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*

# Expose port 28000 to the outside
EXPOSE 28000


# Copy the Pre-built binary file from the previous stage
RUN mkdir -p /app
COPY  current_build/SemaLogic /app
COPY  SemaLogic.svg /app

WORKDIR /app

# Command to run the executable as app
USER app
##ENTRYPOINT [ "/SemaLogic" ]
CMD ["./SemaLogic"]
