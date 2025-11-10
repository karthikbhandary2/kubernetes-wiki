FROM docker:27-dind

# Install k3d + kubectl + helm
RUN apk add --no-cache curl bash jq \
 && curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash \
 && curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
 && chmod +x kubectl && mv kubectl /usr/local/bin/ \
 && curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Copy entrypoint script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Entrypoint
ENTRYPOINT ["/start.sh"]
