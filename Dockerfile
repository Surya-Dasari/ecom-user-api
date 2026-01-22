FROM eclipse-temurin:17-jre

ARG NEXUS_URL
ARG NEXUS_REPO
ARG NEXUS_USER
ARG NEXUS_PASS
ARG GROUP_ID
ARG ARTIFACT_ID
ARG VERSION

WORKDIR /app

RUN curl -fL \
    -u ${NEXUS_USER}:${NEXUS_PASS} \
    -o app.jar \
    ${NEXUS_URL}/repository/${NEXUS_REPO}/com/ecom/user/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}.jar

RUN jar tf app.jar | head -5

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]

