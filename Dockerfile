# ---------- Build stage ----------
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /chat-client
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# ---------- Runtime stage ----------
FROM eclipse-temurin:21-jre-alpine
WORKDIR /chat-client

# REQUIRED for Netty quiche (Anthropic / HTTP2)
RUN apk add --no-cache libgcc

COPY --from=build /chat-client/target/*.jar chat-client-0.0.1-SNAPSHOT.jar

EXPOSE 8081
ENTRYPOINT ["java","-jar","chat-client-0.0.1-SNAPSHOT.jar"]

