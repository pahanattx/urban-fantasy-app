# Use the official NGINX image as the base
FROM nginx:latest

# Remove the default NGINX configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom NGINX configuration
COPY nginx.conf /etc/nginx/conf.d/

# Copy the HTML and CSS files to the NGINX web directory
COPY index.html /usr/share/nginx/html/
COPY about.html /usr/share/nginx/html/
COPY services.html /usr/share/nginx/html/
COPY contact.html /usr/share/nginx/html/
COPY styles.css /usr/share/nginx/html/

# Expose port 80 for web traffic
EXPOSE 80

# Start the NGINX server
CMD ["nginx", "-g", "daemon off;"]