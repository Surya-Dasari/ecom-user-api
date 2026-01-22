FROM eclipse-temurin:17-jre
WORKDIR /app

ARG NEXUS_URL
ARG NEXUS_REPO
ARG NEXUS_USER
ARG NEXUS_PASS
ARG APP_NAME

RUN curl -u ${NEXUS_USER}:${NEXUS_PASS} \
  -o app.jar \
  ${NEXUS_URL}/repository/${NEXUS_REPO}/com/ecom/user/${APP_NAME}/1.0.0/${APP_NAME}-1.0.0.jar

ENTRYPOINT ["java","-jar","app.jar"]

