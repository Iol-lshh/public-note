# 도커 이미지
- 모든 환경을 구성한다.
- 서버, jvm, jar..

# 도커 컨테이너
- 컨테이너는 LXC 원래 Linux Container로, Linux 커널 2008년에 만들어진 내장 기능에서 발전되었다.
  - 도커 컨테이너는 LXC를 이용해서 구현된다.
    - 이젠 defalut로 LXC를 쓰진 않는다. 다른 스키마와 전략을 사용한다.

# 도커 파일
```docker
FROM tomcat:8.516-jre8
MAINTAINER Richard Chesterwood "contact@virtualpairprogrammers.com"
RUN rm -rf ./webapps/*

EXPOSE 8080
ENV JAVA_OPTS="-Dspring.profiles.active=docker-demo"
ADD target/fleetman-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
CMD ["catalina.sh", "run"]
```

- `docker container run -p 8080:8080 virtualpairprogrammers/fleetman-webapp`
    - 외부포트:내부포트


- docker image ls
- docker ps
    - docker ps -a
- docker container ls

- docker --help
- docker container --help

- docker container run -it ubuntu
- docker container stop 아이디
- docker container start 아이디
- docker container rm 아이디
    - 쓰지 않는 컨테이너 메모리에서 삭제
- docker container prune
    - 모든 중단된 컨테이너를 삭제
- docker container run -d ubuntu
    - detached 백그라운드에서 컨테이너 실행
- docker container logs 아이디
    - 컨테이너 로그 확인
- docker container exec 아이디 명령
    - 컨테이너 내부에 명령
    - docker container exec -it 아이디 bash
        - bash 실행

- apline
    - 아주 작은 배포판
- docker pull tomcat:9-alpine



## 도커파일 명령어 특이사항
### ADD, COPY 차이
- ADD 커맨드는 url 가능
    - 아카이브 압축을 풀 수 있다.
- 도커는 COPY를 추천
    - 더 심플하고 명확

### CMD, ENTRYPOINT 차이
- CMD는 default 값
    - 원한다면, 실행 커맨드를 변경 가능하다.
    - Java 서비스를 실행하는 대신에,
        - docker container run에 실행할 커맨드 이름을 추가할 수 있다.
        - `docker container run -it jdk-image-from-dockerfile /bin/bash`
        - 이미지에서 컨테이너가 실행되지만, 기본 커맨드를 재정의한다.
- ENTRYPOINT는 항상 실행
    - 하드코딩된 커맨드
         - docker container run에 실행할 커맨드를 추가해도, 무시하고 서비스를 실행한다.

### MAINTAINER 사용 중단 권고(deprecated), LABEL 사용 추천
- 메타데이터이기에 옵셔널이기는 함

- LABEL은 키 값 쌍 설정 기능
    - 메타데이터 작성 기능
        - [Let’s make your Docker Image better than 90% of existing ones](https://medium.com/@chamilad/lets-make-your-docker-image-better-than-90-of-existing-ones-8b1e5de950d)
        - [label-schema](http://label-schema.org/rc1/)
        - [OpenContainersImage-spec Annotations](https://github.com/opencontainers/image-spec/blob/main/annotations.md)
            - 도커 이외의 컨테이너 시스템 방식을 통합하려는 노력이 담긴 문서
            - 쓸만한 메타데이터 명칭들이 있다.
                - created, authors, url, documentation...
            - 충돌을 피하기 위해, 역방향 DNS 이름을 표준으로 사용한다.
                - 자바 패키지와 흡사
            - BestPractice라 볼 수 있을 것 같다.
    - MAINTAINER 대안으로 사용 권고
    - `MAINTAINER <name>`
    - `LABEL maintainer="SvenDowideiet@home.org.au"`



# Spring Boot app 도커 올리기
- 스프링 부트를 SpringBootServletInitializer를 확장한 애플리케이션 클래스로, 내장 톰캣 외에 서버를 설정할 수 있다.

## TomcatWARApplication.java
```java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * This config class is necessary if running a WAR file under tomcat.
 * Added just so we demo deploying a WAR to a Tomcat image under Docker.
 */
@SpringBootApplication
@EnableScheduling
public class TomcatWARApplication extends SpringBootServletInitializer // SpringBootServletInitializer를 확장한 애플리케이션 클래스
{
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(TomcatWARApplication.class);
    }
    
	public static void main(String[] args) {
		SpringApplication.run(FleetmanApplication.class, args);		
	}
}
```

## pom.xml
```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <!--  For standalone JAR file <configuration><executable>false</executable></configuration> -->
    <configuration>
        <mainClass>com.virtualpairprogrammers.TomcatWARApplication</mainClass>
    </configuration>
</plugin>
```


### 우분투 원시 이미지로부터 시작
```dockerfile
# 원시 베이스 이미지
FROM ubuntu:latest
MAINTAINER Richard Chesterwood "contact@virtualpairprogrammers.com"
RUN apt-get update && apt-get install -y openjdk-8-jdk
CMD ["/bin/bash"]
```

### war로 톰캣 베이스 이미지로부터 앱 시작
- Web Application Archive
    - servlet/jsp 컨테이너에 배치용 압축 파일 포맷
        - jsp는 war만 동작
        - WEB-INF 및 META-INF 디렉토리로 사전 정의 된 구조를 사용
        - 실행하기 위해서는, 웹 서버(WEB) 또는 웹 컨테이너(WAS)가 필요
            - Tomcat, Weblogic, Websphere 등
    - JSP,  SERVLET, JAR, CLASS, XML, HTML, JAVASCRIPT 등  Servlet Context 관련 파일들로 패키징

```dockerfile
# 베이스 이미지
FROM tomcat:8.5.47-jdk8-openjdk
# was 앱
MAINTAINER Richard Chesterwood "contact@virtualpairprogrammers.com"
EXPOSE 8080
RUN rm -rf ./webapps/*
COPY target/fleetman-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
# 액티브 프로파일 이용
ENV JAVA_OPTS="-Dspring.profiles.active=docker-demo"
CMD ["catalina.sh", "run"]
```
- 경로에서 두번째는 목적지
- 포트에서 첫번째는 expose 포트

### jar로 앱 시작
- Java Archive
    - Java(JRE) 위에서 실행하는 압축 파일 포맷
        - 원하는 구조로 구성이 가능
    - Class 파일들, Java 리소스와 속성 파일, 라이브러리 및 액세서리 파일이 포함
```dockerfile
# 베이스 이미지, jdk
FROM openjdk:8u131-jdk-alpine
# jar 앱
MAINTAINER Richard Chesterwood "contact@virtualpairprogrammers.com"
EXPOSE 8080
WORKDIR /usr/local/bin/
COPY target/fleetman-0.0.1-SNAPSHOT.jar webapp.jar

# 액티브 프로파일 이용
CMD ["java","-Dspring.profiles.active=docker-demo","-jar","webapp.jar"]
```

### alpine vs slim
- alpine
    - 아주 작은 Linux 배포판
    - 보안 문제가 좀 있었다고 함
- slim
    - alpine을 대체하는 작은 이미지

# fabric8
- [메이븐 도커 플러그인](https://dmp.fabric8.io/)

# 도커 컴포즈
- 개발 환경을 실행하는 데 필요한 모든 컨테이너의 구성 데이터 전체를 작성한 문서(도커 컴포즈 파일)를 실행하는 툴
- [도커 컴포즈 설치](https://docs.docker.com/compose/install)
    - 확인 `docker-compose -v`
- [compose-file 가이드 문서](https://docs.docker.com/compose/compose-file/04-version-and-name/)

```yaml
version: "3"

# 컨테이너는 시스템 내의 서비스
services:
    # docker container run -d --network fleetman-network --name fleetman-webapp -p 80:8080 virtualpairprogrammers/fleetman-production
    fleetman-webapp:
        image: virtualpairprogrammers/fleetman-production
        networks: 
            - fleetman-network
        ports:
            - 80:8080
        depends_on:
            - database
        
    database:
        image: mysql:5
        networks:
            - fleetman-network
        envirorment: 
            - MYSQL_ROOT_PASSWORD=password
            - MYSQL_DATABASE=fleetman
        
networks:
    fleetman-network:
```
- [스프링 부트 재시작 이슈](https://github.com/spring-projects/spring-boot/issues/4779)
    - [컴포즈 컨테이너 기다리기](https://stackoverflow.com/questions/31746182/docker-compose-wait-for-container-x-before-starting-y)
    - 3버전에서 healthcheck는 포팅되지 못했다. 
        - 이는 도커 컴포즈가 오케스트레이션 시스템을 구축하려 하지 않는다는 입장을 보여주려는 의도라고 한다.
        - 쿠버네티스는 컨테이너가 정상인지 확인하는 작업을 훌륭히 해준다.
    - 문제가 있다면, docker-compose up을 여러번 해주면 된다고 한다...

- `docker-compose up -d`
    - 실행 중인 모든 컨테이너의 상태를 확인하고, 이미지에 변경사항이 있으면, 다시 시작한다.
    - `-d` 옵션은 백그라운드 실행이므로, docker-compose의 작업이 없을때 실행을 보장한다.
- `docker-compose logs -f fleetman-webapp`
    - 해당 앱에 대한 로그를 확인
- 결론: 경합 조건 때문에 시작하지 못한 컨테이너가 있다면, `docker-compose up -d` 를 실행하라..
    - 이건 프로덕션 용이 아니라고 한다..
    - 쿠버네티스 Deployment 기능..
    


