1. AWS CloudWatch Log Group 생성
- 중요도 높은 로그 관리를 위해 **로그 스트림**을 분리
    - 로그 분리.. 로그를 보기 쉽게!
    - 에러만 분리해보자
- CloudWatch > Log groups
    - 로그 그룹 생성
![cloudwatch_create_loggroup](cloudwatch_create_loggroup.png)

2. log stream 관리
- 로그 스트림 생성

3. 스프링 설정
- build.gradle
```gradle
dependencies {
	// log
	implementation 'ca.pjer:logback-awslogs-appender:1.6.0'
	implementation 'org.codehaus.janino:janino:3.1.7'
}
```

- logback.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <!-- 로그 패턴에 색상 적용 %clr(pattern){color} -->
    <conversionRule conversionWord="clr" converterClass="org.springframework.boot.logging.logback.ColorConverter" />
    <property name="CONSOLE_LOG_PATTERN"
              value="[%d{yyyyMMdd'T'HHmmss}] %clr(%-5level) %clr(---){faint} %clr([%thread]){faint} %clr(%-40.40logger{36}){cyan} %clr(:){faint} %msg%n" />

    <property name="FILE_LOG_PATTERN"
              value="[%d{yyyyMMdd'T'HHmmss}] %-5level [%thread] %-40.40logger{36} : %msg%n" />

    <!--appender: 로깅 이벤트 처리 - 0개 이상-->
    <!--    console standard out-->
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <layout class="ch.qos.logback.classic.PatternLayout">
            <Pattern>${CONSOLE_LOG_PATTERN}</Pattern>
        </layout>
    </appender>
    aws appender
    <appender name="ASYNC_AWS_LOGS" class="ca.pjer.logback.AwsLogsAppender">
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>ERROR</level>
        </filter>
        <layout>
            <pattern>${FILE_LOG_PATTERN}</pattern>
        </layout>
        <if condition='property("spring.profiles.active").contains("local")'>
            <then>
                <!-- local 용 로그 그룹명 -->
                <logGroupName>${Log_Group_Name:local}</logGroupName>
            </then>
        </if>
        <if condition='property("spring.profiles.active").contains("dev")'>
            <then>
                <!-- dev 용 로그 그룹명 -->
                <logGroupName>${Log_Group_Name:dev}</logGroupName>
            </then>
        </if>
        <if condition='property("spring.profiles.active").contains("prod")'>
            <then>
                <!-- prod 용 로그 그룹명 -->
                <logGroupName>${Log_Group_Name:prod}</logGroupName>
            </then>
        </if>
        <logStreamUuidPrefix>error-</logStreamUuidPrefix>
        <logRegion>ap-northeast-2</logRegion>
        <maxBatchLogEvents>50</maxBatchLogEvents>
        <maxFlushTimeMillis>30000</maxFlushTimeMillis>
        <maxBlockTimeMillis>5000</maxBlockTimeMillis>
        <retentionTimeDays>0</retentionTimeDays>
    </appender>

<!--    <springProfile name="local">-->
<!--        <logger name="org.springframework" level="INFO">-->
<!--            <appender-ref ref="STDOUT" />-->
<!--        </logger>-->
<!--    </springProfile>-->
    <springProfile name="test">
        <root level="DEBUG">
            <appender-ref ref="STDOUT" />
        </root>
    </springProfile>
    <springProfile name="dev">
        <!--root: 최상단 logger - 최대 1개-->
        <root level="INFO">
            <appender-ref ref="ASYNC_AWS_LOGS" />
        </root>
        <!--logger: 로깅을 남기는 곳 - 0개 이상-->
        <logger name="org.springframework" level="INFO" />
    </springProfile>
</configuration>
```

- <https://logback.qos.ch/codes.html>


# aws CloudWatch로 보내기 위한 인증 방안
- SDK가 필요로 하는 AWS accessKeyId 와 secretKey를 제공해야 합니다. 
    1. AWS_ACCESS_KEY_ID 및 AWS_SECRET_ACCESS_KEY 환경 변수를 설정해서 제공하거나, 
    2. Java 시스템 속성, 
    3. AWS 자격 증명 파일 (일반적으로 ~/.aws/credentials), 
    4. 또는 AWS IAM 역할과 같은 다른 방법들을 사용할 수 있습니다.
- 솔루션: 
    1. 시스템 속성 또는 환경 변수에 AWS_ACCESS_KEY_ID 및 AWS_SECRET_ACCESS_KEY를 설정하거나,
    2. AWS_PROFILE 환경 변수를 설정하거나, ~/.aws/credentials 파일에 프로필을 설정하여 ProfileCredentialsProvider에서 해당 프로필을 로드하도록 하거나,
    3. 컨테이너 또는 EC2 인스턴스 프로필에서 자격 증명을 로드하도록 환경을 조정하실 수 있습니다.
- 조건을 충족한다면, 로컬에서도 보낼 수 있다.

