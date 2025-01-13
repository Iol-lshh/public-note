

# Git 커밋 메시지 작성 가이드
- <https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html>
1. 커밋 메시지는 간결하고 명료하게 작성하는 것이 중요
2. 메시지는 두 부분으로 구성
    - 50자 이내의 제목 줄
    - 필요한 경우, 더 자세한 설명을 담은 본문
3. 제목 줄은 변경 사항의 요약이며 본문은 기술적인 세부 사항을 제공
4. 제목 줄은 명령형으로 작성합 (예: "fixed bug"이 아니라 "fix bug").
5. 본문은 72자 안에 줄 바꿈 (이메일과 유사하게 읽기 쉽게 하기 위해).
6. 이메일, git log, gitk, GitHub 등 다양한 곳에서 사용
```diff
title: 로그인 시스템 개선 (SSO 지원 추가)
contents:
    - SSO 인증 제공 업체와 연동하는 코드 추가
    - 기존 로그인 로직 유지
    - 테스트 코드 추가
```

## 추가 고려
- 불필요한 단어는 생략
- 명확한 동사를 사용
- 변경 사항에 따라 관련 이슈 번호를 참조
- 일관성 유지 (팀 내 기준 따르기).

# Maven 반영
## OSS 순서
1. 프로젝트 설계
    - 프로젝트를 설계할 때에는 다음과 같은 사항을 고려

2. 라이선스
    - 프로젝트에 사용할 라이선스를 선택
    - Apache License 2.0, MIT License, GNU General Public License v3.0과 같은 오픈소스 라이선스

3. 패키지 구조
    - 프로젝트의 패키지 구조를 설계 
    - 패키지 구조는 프로젝트의 구조를 명확하게 보여주고, 다른 개발자들이 프로젝트를 이해하고 사용할 수 있도록 한다.

4. 의존성
    - 프로젝트에서 사용할 의존성을 파악
    - 의존성은 프로젝트를 실행하는 데 필요한 라이브러리와 프레임워크를 의미

5. 소스 코드 작성
    - 프로젝트 설계 단계에서 결정한 사항을 바탕으로 소스 코드 작성
    - 소스 코드는 프로젝트의 기능을 구현하는 코드

6. 테스트 작성
    - 소스 코드 작성이 완료되면, 테스트 코드를 작성 
    - 테스트 코드는 소스 코드의 오류를 검출하는 데 사용

7. 프로젝트 빌드
    - 테스트 코드 작성이 완료되면, 프로젝트를 빌드 
    - 빌드는 프로젝트의 소스 코드를 컴파일하고, 의존성을 설치하는 과정

8. 프로젝트 배포
    - 프로젝트 빌드가 완료되면, 프로젝트를 배포

## 메이븐을 사용하여 프로젝트를 배포하는 방법
### 1. 패키지 생성
```shell
# 프로젝트 패키지화
mvn clean package
mvn package
```
### 2. 메이븐에 패키지 등록
```shell
# 패키지화된 프로젝트를 원격 메이븐 리포지토리에 배포
mvn deploy
```
### 3. 패키지 설치 및 사용
```shell
# 패키지화된 프로젝트를 로컬 메이븐 리포지토리에 설치
mvn install
```

## 고려
### 1. 라이선스
- 프로젝트에 사용할 라이선스를 선택하는 것은 매우 중요합니다. 라이선스는 프로젝트의 소스 코드를 사용할 수 있는 권한을 결정합니다.

### 2. 패키지 구조
- 프로젝트의 패키지 구조는 프로젝트의 구조를 명확하게 보여주고, 다른 개발자들이 프로젝트를 이해하고 사용할 수 있도록 도와줍니다. 패키지 구조를 설계할 때에는 다음과 같은 사항을 고려해야 합니다.
    - 프로젝트의 기능을 기반으로 패키지를 분류합니다.
    - 패키지 이름을 명확하게 지정합니다.
    - 패키지 간 관계를 명확하게 정의합니다.

### 3. 의존성
- 프로젝트에서 사용할 의존성을 파악하는 것은 매우 중요합니다. 의존성은 프로젝트를 실행하는 데 필요한 라이브러리와 프레임워크를 의미합니다. 의존성을 파악할 때에는 다음과 같은 사항을 고려해야 합니다.
    - 프로젝트의 기능에 필요한 의존성을 파악합니다.
    - 의존성의 버전을 명확하게 지정합니다.
    - 의존성의 라이선스를 확인합니다.


## 설계 단계 고려 사항
1. pom.xml 파일에 프로젝트에 필요한 모든 의존성을 정확하게 명시
    - 메이븐이 프로젝트를 빌드하고 패키지화하는 데 필요한 모든 라이브러리를 알 수 있도록
2. 프로젝트의 groupId, artifactId, version 설정 
    - 이 정보는 메이븐 리포지토리에서 프로젝트를 식별하는데 사용
3. [메이븐 distributionManagement](#메이븐-distributionmanagement) 설정
    - 프로젝트가 어떤 메이븐 리포지토리에 배포될지 지정
4. 프로젝트의 소스 코드 구조가 메이븐의 표준 디렉토리 레이아웃을 따르고 있는지 확인
    - 메이븐이 프로젝트의 소스 코드를 올바르게 컴파일하고 패키지화할 수 있도록
5. 프로젝트의 테스트 코드가 메이븐의 표준 테스트 프레임워크와 호환되는지 확인
    - 메이븐이 프로젝트의 테스트를 올바르게 실행하고 결과를 보고할 수 있도록

### 메이븐 distributionManagement
- 프로젝트를 배포하기 위한 정보를 정의하는 태그
- 프로젝트의 패키지를 배포할 위치와 방식을 정의
1. repository
- 패키지를 배포할 리포지토리의 정보를 정의
    - id 속성: 리포지토리의 ID
    - name 속성: 리포지토리의 이름
    - url 속성: 리포지토리의 URL
2. snapshotRepository
- 스냅샷 버전의 패키지를 배포할 리포지토리의 정보를 정의
- repository 태그의 속성과 동일
3. site 
- 프로젝트의 사이트 정보를 정의
    - id 속성: 사이트의 ID
    - name 속성: 사이트의 이름
    - url 속성: 사이트의 URL
```xml
<distributionManagement>
    <repository>
        <id>my-repository</id>
        <name>My Repository</name>
        <url>https://my-repository.com/</url>
    </repository>
    <snapshotRepository>
        <id>my-snapshot-repository</id>
        <name>My Snapshot Repository</name>
        <url>https://my-snapshot-repository.com/</url>
    </snapshotRepository>
    <site>
        <id>my-site</id>
        <name>My Site</name>
        <url>https://my-site.com/</url>
    </site>
</distributionManagement>
```
- 프로젝트의 패키지는 my-repository 리포지토리에 배포
- 스냅샷 버전의 패키지는 my-snapshot-repository 리포지토리에 배포
- 프로젝트의 사이트는 my-site 리포지토리에 배포


# 예시
- https://github.com/spring-cloud/spring-cloud-netflix

## 행동 강령
- https://opensource.microsoft.com/codeofconduct/
- https://github.com/Azure/iotedge?tab=readme-ov-file
- https://github.com/mozilla/inclusion

## 기여 가이드
- https://github.com/Azure/iotedge/blob/main/doc/devguide.md
- https://github.com/github/opensource.guide/blob/main/CONTRIBUTING.md

## 가이드
- https://github.com/github/opensource.guide/blob/main/docs/content-model.md
- https://github.com/github/opensource.guide/blob/main/docs/styleguide.md

## 라이센스
- https://www.apache.org/licenses/LICENSE-2.0.html
