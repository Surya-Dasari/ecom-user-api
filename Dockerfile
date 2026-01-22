FROM eclipse-temurin:17-jre

ARG NEXUS_URL
ARG NEXUS_REPO
ARG NEXUS_USER
ARG NEXUS_PASS
ARG GROUP_ID=com.ecom.user
ARG ARTIFACT_ID=ecom-user-api
ARG VERSION=1.0.0

WORKDIR /app

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

RUN curl -f -u ${NEXUS_USER}:${NEXUS_PASS} \
  -o app.jar \
  ${NEXUS_URL}/repository/${NEXUS_REPO}/$(echo ${GROUP_ID} | tr '.' '/')/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]

