# 도커 파일
- 빌드와 실행으로 단계를 나눈다.
```dockerfile
# Dockerfile
# Build Stage
FROM gradle:jdk17-alpine as builder
WORKDIR /build

# Gradle 프로젝트의 빌드 파일 및 소스 코드를 복사
COPY build.gradle settings.gradle ./
COPY src/ ./src/
RUN gradle build

# Runtime Stage
FROM openjdk:17-slim
WORKDIR /app

# 빌드된 어플리케이션 JAR 파일을 복사
COPY --from=builder /build/build/libs/api-repository-0.0.1-SNAPSHOT.jar ./myapp.jar
# 어플리케이션을 실행
CMD ["java", "-jar", "myapp.jar"]
```


# 컴포즈 파일
```yaml
version: '3'
services:
  myapp:
    ## 빌드할 이미지의 도커 파일 위치, 도커 파일 이름
    build:
      context: "./"
      dockerfile: Dockerfile
    container_name: "my-app"
    # networks:
    #   -
    ports:
      - "80:80"
    # env_file:
    #   - .env
    #   - .env.dev
    environment:
      ## ${PHASE_NAME}: dev, stg, prod
      SPRING_PROFILES_ACTIVE: ${PHASE_NAME}
      SPRING_DATASOURCE_URL: jdbc:${DB_RDBMSNAME}://${DB_HOSTNAME}:${DB_PORT}/${DB_NAME}
      SPRING_DATASOURCE_USERNAME: ${DB_USERNAME}
      SPRING_DATASOURCE_PASSWORD: ${DB_PASSWORD}
    # volumes:
    #   -
    # depends_on:
    #   -  
```

## .env
```dotenv
## PROFILES
PHASE_NAME=dev

## DATASOURCE
# DB_HOSTNAME=postgres-db
DB_HOSTNAME=172.30.1.9
DB_PORT=5432
DB_NAME=api_repository
DB_USERNAME=lshh
DB_PASSWORD=lshh.com

## JWT
#JWT_SECRET=mySecretKey
```

