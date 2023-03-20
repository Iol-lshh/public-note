> [Home](../README.md)

- [4. SpringBoot](#4-springboot)
    - [4.0 Spring](#40-spring)
        - [4.0.1 특징](#401-특징)
        - [4.0.2 SpringBoot](#402-springboot)
    - [4.1 gradle](#41-gradle)
        - [4.1.1 버전](#411-버전)
        - [4.1.2 의존성](#412-의존성)
    - [4.2 설정 관리](#42-설정-관리)
    - [4.3 컴포넌트](#43-컴포넌트)
        - [4.3.1 controller](#431-controller)
        - [4.3.2 service](#432-service)
    - [4.4 domain 컴포넌트](#44-domain-컴포넌트)
        - [4.4.0 dto](#440-dto)
        - [4.4.1 JPA](#441-jpa)
            - [4.4.1.0 설정](#4410-설정)
            - [4.4.1.1 entity](#4411-entity)
                - [4.4.1.1.1 관계](#44111-관계)
            - [4.4.1.2 repository](#4412-repository)
    - [4.5 queryFactory](#45-queryfactory)
        - [4.5.1 QueryFactory](#451-queryfactory)
            - [4.5.1.1 plain text query](#4511-plain-text-query)
            - [4.5.1.2 User Saved Procedure](#4512-user-saved-procedure)
            - [4.5.1.3 MyBatis](#4513-mybatis)
        - [4.5.2 QueryStatement](#452-querystatement)
            - [4.5.2.1 TextQueryStatement](#4521-textquerystatement)
            - [4.5.2.2 ProcedureQueryStatement](#4522-procedurequerystatement)
            - [4.5.2.3 MyBatisQueryStatement](#4523-mybatisquerystatement)


# 4. SpringBoot
## 4.0 Spring
## 4.0.1 특징
1. 간단한 자바 오브젝트 POJO Plain Old Java Object
    - 경량, 적은 의존성, 추상화로 재활용성이 좋다.
    1. 서비스 추상화 PSA - Portable Service Abstraction
    2. 제어 역행 Ioc - Inversion of Control
    3. 의존성 주입 DI - Dependency Injection
    4. 관점지향 프로그래밍 AOP - Aspect Oriented Programming
        - Filter, Interceptor, AOP
2. 오픈소스
3. 경량 컨테이너
    - 싱글톤으로 자바 객체를 직접 관리
4. 영속성 컨테이너 지원
    - MyBatis(Query Mapper), JPA(ORM)
5. 트랜잭션 관리 지원
6. MVC 모델-뷰-컨트롤러 패턴 지원
7. 배치 프레임워크 지원(Quartz 기반)

## 4.0.2 SpringBoot
- 스프링에 필수적인 의존성들을 얹힌 것
    1. 자주 사용되는 라이브러리들의 버전 관리 자동화
    2. AutoConfig로 복잡한 설정 자동화
    3. 내장 웹서버 제공
    4. 실행 가능한 JAR로 개발 가능


## 4.1 gradle
- [build.gradle](../build.gradle)에 수록
### 4.1.1 버전
```gradle
plugins {
	id 'java'
	id 'org.springframework.boot' version '3.0.3'
	id 'io.spring.dependency-management' version '1.1.0'
}

group = 'chunjae'
sourceCompatibility = '17'
```

### 4.1.2 의존성
```gradle
implementation 'org.springframework.boot:spring-boot-starter-data-rest'
implementation 'org.springframework.boot:spring-boot-starter-thymeleaf'	
implementation 'org.springframework.boot:spring-boot-starter-web'
implementation 'org.springframework.boot:spring-boot-starter-actuator'
implementation 'org.springframework.boot:spring-boot-starter-jdbc'
implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
implementation 'org.beanshell:bsh-core:2.0b4'
implementation 'javax.persistence:javax.persistence-api:2.2'
implementation group: 'com.googlecode.json-simple', name: 'json-simple', version: '1.1.1'
compileOnly 'org.projectlombok:lombok'
developmentOnly 'org.springframework.boot:spring-boot-devtools'
runtimeOnly 'com.microsoft.sqlserver:mssql-jdbc'
annotationProcessor 'org.projectlombok:lombok'
testImplementation 'org.springframework.boot:spring-boot-starter-test'
```

## 4.2 설정 관리
- [application.yml](../src/main/resources/application.yml)에 수록
- yml 확장자 방식 적용
- 필요시, 적확한 이름의 설정 파일 추가 관리
- 싱글톤 컴포넌트에서의 `@Value` 활용 지향

## 4.3 컴포넌트
### 4.3.1 controller
- `@RestController`
    - `org.springframework.web.bind.annotation.RestController`
- 서비스 `@Autowired` 활용
    - DI 요소가 다형성을 갖는다면, 생성자를 통한 DI를 활용한다.


### 4.3.2 service
- `@Service`
    - `org.springframework.stereotype.Service`
- 반드시, 인터페이스와 구현체로 분리한다.
    - 인터페이스를 통해, 소스의 코드 문서화를 지향한다.
    - `default` 접근자를 이용하여, 구현과 로직을 분리하여, 함수의 기능을 단일화한다.
    - 함수는 반드시 <span style="color:red">**명확한 한가지 기능**</span>만을 갖추며, 적확한 이름을 가져야 한다.
    - Null 처리시, [Optional](./doc_Java_Style.md#34-optional---null-처리)을 활용한 처리를 지향한다.
```java
// 서비스 인터페이스
public interface HomeService {
    // 리스트
    ContantList<String, Object> getList(HashMap<String, Object> map) throws Exception;

    // 뷰
    Map<String, Object> getView(HashMap<String, Object> map) throws Exception;

    // 쓰기
    @Transactional(propagation = Propagation.REQUIRED, isolation = Isolation.READ_UNCOMMITTED)
    default SaveResult setWrite(List<MultipartFile> files, LcmsNoticeDto dto) throws Exception{     // default 접근자를 이용하여, 템플릿 메소드 패턴을 구현한다.
        // 1. upload file
        List<String> ff = saveFiles(files);

        // 2. save
        if(dto.getIdx() == null || dto.getIdx() == 0)
            create(dto, ff);
        else
            update(dto, ff);

        // 3. result
        return SaveResult.SUCCESS;
    }

    // 파일 저장
    List<String> saveFiles(List<MultipartFile> files) throws IllegalStateException, IOException;

    // db row 생성
    LcmsNotice create(LcmsNoticeDto dto, List<String> ff) throws Exception;

    // db row 수정
    LcmsNotice update(LcmsNoticeDto dto, List<String> ff) throws NoSuchElementException;
}

//////////////////
// 서비스 구현체 //
@Service
public class HomeServiceImpl implements HomeService{

    @Autowired
    LcmsNoticeRepository noticeRepo;
    @Autowired
    FileIoHelper fileIoHelper;
    @Autowired
    DataSource dataSource;
    @Autowired
    QueryFactory queryFactory;

    @Override
    public ContantList<String, Object> getList(HashMap<String, Object> map) throws Exception{
// ~~생략~~
```

- 전역 속성을 지양
    - 고정 상수는 인터페이스에 작성
    - 설정 상수는 `@Value`를 이용하여, .yml에 작성


## 4.4 domain 컴포넌트
### 4.4.0 dto
- Request를 위해 이용될 경우, `@JsonProperty`를 활용한다.
    - `com.fasterxml.jackson.annotation.JsonProperty`
- 불변성을 지향한다.
    - Setter 함수를 구현하지 않는 것도 한가지 방법

### 4.4.1 JPA
#### 4.4.1.0 설정
- 반드시, ddl-auto를 비활성화한다.
- 물리 전략을 이용한다. 
```yml
spring:
    jpa:
        hibernate:
            ddl-auto: none
            naming:
                physical-strategy: org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
        properties:
            hibernate:
                show_sql: true
                format_sql: true
                use_sql_comments: true
```

#### 4.4.1.1 entity
- `@Entity`
    - `jakarta.persistence.Entity`
- 테이블 명을 명시한다.
    - `@Table(name = "TBL_LCMS_Notice")`
- 컬럼 명, 데이터 타입을 명시한다.
    - `@Column(name = "Idx")`
    - `@Column(name = "UserID", columnDefinition = "varchar", length = 50)`

- 롬복을 이용한 Setter 구현시, `@Accessors(chain = true)` 옵션 이상을 준다.
    - `lombok.experimental.Accessors`
- Entity 동적 쿼리 기능 
    - `@DynamicInsert`, `@DynamicUpdate` 두 가지 옵션을 반드시 준다.
        - `org.hibernate.annotations`
        - 해당 어노테이션 적용시, 없는 컬럼은, 기존 디비 데이터로 처리된다.
- `@ColumnDefault()`을 작성을 지향한다.
- 날짜 등의 정보는 상속받는다.
    - 시간은 LocalDate/LocalTime/LocalDateTime을 이용한다.
        - `java.time`
- 참/거짓의 데이터일 경우, getter/setter를 boolean 값과 연계하여 만드는 것을 추천한다.
    - 롬복을 사용한다면, `@Getter(AccessLevel.NONE)`, `@Setter(AccessLevel.NONE)`를 통해, 자동 getter/setter 생성을 막고, 직접 구현하는 것을 추천한다.
```java
@Accessors(chain = true)
@Data
@DynamicInsert
@DynamicUpdate
@Table(name = "TBL_LCMS_Notice")
@Entity
public class LcmsNotice {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Idx")
    private Integer idx;

    @Getter(AccessLevel.NONE)   // 롬복이 이 필드의 Getter를 자동 생성하지 않는다.
    @Setter(AccessLevel.NONE)   // 롬복이 이 필드의 Setter를 자동 생성하지 않는다.
    @ColumnDefault("'N'")
    @Column(name = "DeleteYN", columnDefinition = "char", length = 1)
    private String deleteYN;

    // Getter 1: DB 데이터가 "Y"라면 true를 반환한다.
    public boolean isDeleted(){
        return this.deleteYN.equals("Y") ? true : false;
    }

    // Getter 2: DB 데이터 그대로 반환한다.
    public String getDeleteYN(){
        return this.deleteYN;
    }

    // Setter 1: true 값을 받는다면, "Y"를 입력한다.
    public LcmsNotice setDeleteYN(boolean deleted){
        this.deleteYN = deleted ? "Y" : "N";
        return this;
    }

    // Setter 2: 오버로딩, "Y"를 그대로 입력한다.
    public LcmsNotice setDeleteYN(String deleteYN){
        this.deleteYN = deleteYN;
        return this;
    }
}
```

##### 4.4.1.1.1 관계
- Lazy 전략을 지향한다.
    - 서비스 단에서, `@Transactional(propagation = Propagation.REQUIRED, isolation = Isolation.READ_UNCOMMITTED)` 트랜잭션 사용을 추천한다.
        - 전파: 필요함 (없을 경우, 트랜잭션 생성)
        - 고립성: READ UNCOMMITTED
- n : m 구현시, 중간 객체를 따로 구현하는 것을 추천한다.
- Join이 인덱스를 타는 설계를 지향한다.

```java
// 1
public class AssignRole {
    @Id
    @Column(name = "assign_id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long assignId;

    @OneToMany(mappedBy = "assignRole" )
    private List<LoopAssign> loopAssignList  = new ArrayList<LoopAssign>();
}

// n
public class LoopAssign {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long loopAssignId;

    @ManyToOne(targetEntity = AssignRole.class, fetch = FetchType.LAZY)
    @JoinColumn(name="assign_id")
    private AssignRole assignRole;
}
```

#### 4.4.1.2 repository
- `JpaRepository<엔티티명, 엔티티 식별자id 타입>`
    - `org.springframework.data.jpa.repository.JpaRepository`
- entity 조회시, 기본적으로 Optional로 받는다.
```java
Optional<LcmsNotice> findLcmsNoticeByIdx(int idx);
```
- Optional을 단순 get으로 받는 것을 지양한다.
- 하드 딜리트를 지양한다.
    - 소프트 딜리트를 지향하여, `notDeleted` 속성으로 처리하자.

```java
@Override
@Transactional(propagation = Propagation.REQUIRED, isolation = Isolation.READ_UNCOMMITTED)
public LcmsNotice update(LcmsNoticeDto dto, List<String> ff) throws NoSuchElementException{
    return noticeRepo.save(noticeRepo
                                .findLcmsNoticeByIdx(dto.getIdx())
                                .orElseThrow(() -> new NoSuchElementException("찾는 글이 없습니다."))
                                .setUserID(dto.getUserId())
                                .setTitle(dto.getTitle())
                                .setContent(dto.getContent())
                                .setAttachFile1(ff.get(0) != FileIoResult.NO_SIZE.name() ? ff.get(0) : "")
                                .setAttachFile2(ff.get(1) != FileIoResult.NO_SIZE.name() ? ff.get(1) : ""));
}
```

## 4.5 queryFactory
- 다음 세가지 방식의 DB 요청을 지원한다.
    - plain text query - 일반 텍스트 쿼리
    - User Saved Procedure - 사용자 저장 프로시저
    - MyBatis

### 4.5.1 QueryFactory
- `chunjae.api.common.queryFactory.QueryFactory`
- 작성할 쿼리문에 대한 객체를 생성해준다.
    - 설정을 갖는다.
- `BasicQueryFactory`로 구현된다.

#### 4.5.1.1 plain text query
- `createTextStatement()`
- `common.queryFactory.TextQueryStatement`를 반환한다.

#### 4.5.1.2 User Saved Procedure
- `createProcedureStatement()`
- `common.queryFactory.ProcedureQueryStatement`를 반환한다.

#### 4.5.1.3 MyBatis
- `createMyBatisStatement()`
- `common.queryFactory.MyBatisQueryStatement`를 반환한다.

### 4.5.2 QueryStatement
- `chunjae.api.common.queryFactory.QueryStatement`
- 쿼리문을 작성하는 객체
- 구현체를 통해 세부 방법이 나뉘며, 해당 방법을 통해 데이터베이스와 연결된다.
- `set`: 쿼리의 본문을 작성할 수 있다.
- `addParam`: 본문의 파라미터를 넣을 수 있다.
- `clearParams`: 입력된 파라미터들을 지울 수 있다.
- `query~`: 쿼리를 디비로 전송해, 조회할 수 있다.
- `command`: 쿼리를 디비로 전송해, 쓰기할 수 있다.

```java
public interface QueryStatement {
    
    // # set 메서드에 이용할 프로퍼티 타입
    enum PropertyName {
        PATH_NAME, QUERY_TEXT, SP_NAME
    }
    
    // # param 클래스
    @Getter
    @Setter
    public class Parameter {
        enum ParameterType {INPUT, OUTPUT}
        
        public String key;
        public Object val;
        public ParameterType type;
    }

    // # property 제어
    QueryStatement set(String val);
    QueryStatement set(PropertyName property, String val) throws Exception;

    // # param 제어
    // ## param 모두 제거
    QueryStatement clearParams();
    
    // ## param 추가
    QueryStatement addParam(String key, Object val);
    QueryStatement addParam(String key, Object val, ParameterType type);
    
    // select
    ContantList<String, Object> queryMap() throws Exception;
    <T> List<T> queryByClass(Class<T> theClass) throws Exception;
    Map<String, Object> queryScalar() throws Exception;
    <T> T queryScalarByClass(Class<T> theClass) throws Exception;
    
    // insert, update
    SetResult command();
}
```


#### 4.5.2.1 TextQueryStatement
- `chunjae.api.common.queryFactory.TextQueryStatement`
- 일반 텍스트 문자열로 쿼리를 주어 실행한다.
- 지원하는 `PropertyName`은 다음과 같다.
    - `QUERY_TEXT`: 실행할 쿼리 문자열

```java
queryFactory
    .createTextStatement()      // TextQueryStatement 객체 반환
    .set("SELECT * FROM TBL_LCMS_Notice Where Idx = @in_Idx")
    .addParam("@in_Idx", map.get("idx"))
    .queryScalar();
```

#### 4.5.2.2 ProcedureQueryStatement
- `chunjae.api.common.queryFactory.ProcedureQueryStatement`
- 프로시저 명을 주어 실행한다.
- 지원하는 `PropertyName`은 다음과 같다.
    - `SP_NAME`: 실행할 프로시저 명

#### 4.5.2.3 MyBatisQueryStatement
- `chunjae.api.common.queryFactory.MyBatisQueryStatement`
- MyBatis용 json 파일을 가져와 실행한다.
- 지원하는 `PropertyName`은 다음과 같다.
    - `PATH_NAME`: mybatis json 파일의 경로 및 파일 명

```java
queryFactory
    .createMyBatisStatement()      // MyBatisQueryStatement 객체 반환
    .set("/home/list")
    .addParam("@in_PageNo", map.get("pageno"))
    .addParam("@in_ListSize", map.get("listsize"))
    .addParam("@in_Key", map.get("key"))
    .addParam("@in_Val", map.get("val"))
    .queryMap();
```
