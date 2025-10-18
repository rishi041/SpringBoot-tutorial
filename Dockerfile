# ---------- Build stage ----------
FROM maven:3.9.8-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml ./
# speed up: go offline for deps
RUN mvn -B -q -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -B -DskipTests package

# ---------- Run stage ----------
FROM eclipse-temurin:21-jre
WORKDIR /app
# copy the built jar (matches your target/*.jar)
COPY --from=build /app/target/*.jar app.jar

# non-root user
RUN useradd -ms /bin/bash appuser
USER appuser

# Render will set PORT; we expose 8080 inside the container
EXPOSE 8080
ENV JAVA_OPTS=""
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]
