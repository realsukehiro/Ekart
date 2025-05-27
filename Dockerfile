FROM openjdk:11-jre-slim
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8070
CMD ["java", "-jar", "app.jar"]