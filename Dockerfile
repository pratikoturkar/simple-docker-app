FROM nginx:alpine
ARG APP_NAME=DefaultApp
RUN echo "<h1>Hello from ${APP_NAME}</h1>" > /usr/share/nginx/html/index.html
