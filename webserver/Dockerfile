# FROM nginx:1.27.1-alpine-slim
# to ensure you're pulling the same image every time, a digest is used
FROM nginx@sha256:087f90d16ce1004cf11671e229b62cc36dca1b837870aa357983954a46034d33

# Expose the port
EXPOSE 80

# Copy only the necessary file
COPY index.html /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]