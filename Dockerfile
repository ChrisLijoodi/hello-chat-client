# ---------- Build stage ----------
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /chat-client
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
#RUN mvn clean package -DskipTests
RUN mvn -B clean package -DskipTests

# ---------- Runtime stage ----------
#FROM eclipse-temurin:21-jre-alpine
FROM eclipse-temurin:21-jre-jammy
WORKDIR /chat-client

# REQUIRED for Netty quiche (Anthropic / HTTP2)
#RUN apk add --no-cache libgcc
RUN apt-get update && apt-get install -y \
    libgcc-s1 \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /chat-client/target/*.jar chat-client-0.0.1-SNAPSHOT.jar

EXPOSE 8081
#ENTRYPOINT ["java","-jar","chat-client-0.0.1-SNAPSHOT.jar"]
ENTRYPOINT ["java", \
  "-XX:MaxRAMPercentage=75", \
  "-Djava.security.egd=file:/dev/urandom", \
  "-Djava.net.preferIPv4Stack=true", \
  "-jar", "chat-client-0.0.1-SNAPSHOT.jar"]

## ---------- Build stage ----------
#FROM maven:3.9.6-eclipse-temurin-21 AS build
#WORKDIR /chat-client
#
## Cache dependencies first
#COPY pom.xml .
#RUN mvn -B -q dependency:go-offline
#
## Build application
#COPY src ./src
#RUN mvn -B clean package -DskipTests
#
#
## ---------- Runtime stage ----------
#FROM eclipse-temurin:21-jre-jammy
#WORKDIR /chat-client
#
## 🔑 Required native + TLS dependencies for Spring AI / Anthropic
#RUN apt-get update && apt-get install -y \
#    libgcc-s1 \
#    ca-certificates \
# && rm -rf /var/lib/apt/lists/*
#
## Copy built jar
#COPY --from=build /chat-client/target/*.jar app.jar
#
## Render uses PORT env var
#EXPOSE 8081
#
## JVM flags tuned for containers + networking
#ENTRYPOINT ["java", \
#  "-XX:MaxRAMPercentage=75", \
#  "-Djava.security.egd=file:/dev/urandom", \
#  "-Djava.net.preferIPv4Stack=true", \
#  "-jar", "app.jar"]


