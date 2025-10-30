# Step 1: Use lightweight web server image
FROM nginx:latest

# Step 2: Copy website files into nginx html directory
COPY . /usr/share/nginx/html

# Step 3: Expose default port
EXPOSE 80

# Step 4: Default command
CMD ["nginx", "-g", "daemon off;"]
