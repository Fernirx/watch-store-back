# Stage 1: Build
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Run Spring Boot app
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=builder /app/tawatch-starter/target/*.jar app.jar
RUN groupadd -g 1001 spring && useradd -u 1001 -g spring -m spring
USER spring:spring
ENTRYPOINT ["java", "-jar", "app.jar"]