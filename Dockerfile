# ---------- Build stage ----------
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /chat-client

COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B clean package -DskipTests

# ---------- Runtime stage ----------
FROM eclipse-temurin:21-jre-jammy
WORKDIR /chat-client

# REQUIRED for Netty quiche (Anthropic / HTTP2)
RUN apt-get update && apt-get install -y \
    libgcc-s1 \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY --from=build /chat-client/target/*.jar chat-client-0.0.1-SNAPSHOT.jar

EXPOSE 8081
ENTRYPOINT ["java", \
  "-XX:MaxRAMPercentage=75", \
  "-Djava.security.egd=file:/dev/urandom", \
  "-Djava.net.preferIPv4Stack=true", \
  "-jar", "chat-client-0.0.1-SNAPSHOT.jar"]

