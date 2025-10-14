# 9.2
- Use the mvn -s settings.xml package command to create the /home/jboss/target/beeper-1.0.0.jar binary file.

- Run the java -jar beeper-1.0.0.jar command to start the Beeper API.

- Run the npm install command in the application directory to install build dependencies within the image.

- Run the npm run build command in the application directory to build the application. This command saves the built artifacts in the /opt/app-root/src/dist directory.

- Use the nginx -g "daemon off;" command to start the application.


```
FROM registry.ocp4.example.com:8443/ubi9/nodejs-22:1 AS builder
USER root
COPY . .
RUN npm install && \
    npm run build

FROM registry.ocp4.example.com:8443/ubi8/nginx-118:1
COPY nginx.conf /etc/nginx/
COPY --from=builder /opt/app-root/src/dist /usr/share/nginx/html
CMD nginx -g "daemon off;"
```

# 4.7

- The ./gen_certificates.sh command is included in the provided container.

- In the final stage of the Containerfile, run the npm install --omit=dev command to install the production dependencies of the Node.js application. Then, build the container image with the name localhost/podman-qr-app.

- In the final stage of the Containerfile, make npm start the default command for this image. Additional runtime arguments should not override the default command. Then, build the container image with the name localhost/podman-qr-app.

```
FROM \
  registry.ocp4.example.com:8443/redhattraining/podman-certificate-generator \
  as certs

RUN ./gen_certificates.sh

FROM registry.ocp4.example.com:8443/ubi9/nodejs-22:1
USER root
RUN groupadd -r student && useradd -r -m -g student student && \
    npm config set cache /tmp/.npm --global

COPY --from=certs --chown=student:student /app/*.pem /etc/pki/tls/private/certs/
COPY --chown=student:student . /app/

ENV TLS_PORT=8443 \
    HTTP_PORT=8080 \
    CERTS_PATH="/etc/pki/tls/private/certs"

WORKDIR /app

USER student

RUN npm install --omit=dev

ENTRYPOINT npm start
```