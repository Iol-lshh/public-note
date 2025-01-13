# 베이스 이미지
FROM eclipse-temurin:17-jre AS base
# 경로
ARG JAR_FILE="build/libs/eureka-server-0.0.1-SNAPSHOT.jar"
# 복사
COPY ${JAR_FILE} eureka-server.jar
# 실행
ENTRYPOINT ["java","-jar","/eureka-server.jar"]


#############
FROM gradle:jdk17-alpine as builder
WORKDIR /build

# 그래들 파일이 변경되었을 때만 새롭게 의존패키지 다운로드 받게함.
COPY build.gradle.kts settings.gradle.kts /build/
RUN gradle build -x test --parallel --continue > /dev/null 2>&1 || true

# 빌더 이미지에서 애플리케이션 빌드
COPY . /build
RUN gradle build -x test --parallel

# APP
FROM openjdk:17.0-slim
WORKDIR /app

# 빌더 이미지에서 jar 파일만 복사
COPY --from=builder /build/build/libs/my-app-0.0.1-SNAPSHOT.jar .

EXPOSE 8080

# root 대신 nobody 권한으로 실행
USER nobody
ENTRYPOINT [                                                \
    "java",                                                 \
    "-jar",                                                 \
    "-Djava.security.egd=file:/dev/./urandom",              \
    "-Dsun.net.inetaddr.ttl=0",                             \
    "my-app-0.0.1-SNAPSHOT.jar"              \
]



##############
# 멀티스테이지 빌드의 첫 번째 스테이지
FROM gradle:jdk17-alpine as builder

WORKDIR /build

# Gradle 프로젝트의 빌드 파일 및 소스 코드를 복사합니다.
COPY build.gradle settings.gradle ./
COPY src/ ./src/

# 프로젝트를 빌드합니다.
RUN gradle build

# 두 번째 스테이지: 빌드된 어플리케이션을 실행하는 베이스 이미지
FROM openjdk:17-slim
WORKDIR /app

# 빌드된 어플리케이션 JAR 파일을 복사합니다.
COPY --from=builder /app/build/libs/*.jar app.jar

# 어플리케이션을 실행합니다.
CMD ["java", "-jar", "app.jar"]
