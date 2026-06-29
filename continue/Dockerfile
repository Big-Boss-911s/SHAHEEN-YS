# ============================================================
# SHAHEEN-YS — Continue AI Config Server
#
# A lightweight Nginx container that serves the Continue AI
# config.json to the VS Code extension over HTTP.
#
# The extension is configured to fetch its config from:
#   http://localhost/continue/config.json
# ============================================================

FROM nginx:1.27-alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy our minimal serving config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy Continue config files
COPY config/ /usr/share/nginx/html/

# Expose port 8080 (matched by docker-compose.yml upstream)
EXPOSE 8080

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -qO- http://localhost:8080/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
