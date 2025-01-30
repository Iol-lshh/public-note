# Jenkins Job DSL
- 프로그래밍 방식으로 작업을 정의하는 젠킨스 플러그인
- Domain Specific Language
- Groovy 기반 언어로 작성
    - Groovy: 자바 플랫폼의 언어
        - Java와 비슷하나, 더 dynamic하고 simple하다.
        - 스크립트 언어

# Job DSL groovy 파일 예시    
```groovy
job('NodeJS example'){     // job의 이름
    // 버전 관리 정보
    scm {
        git('git://github.com/wardviaene/docker-demo.git'){ node->
            node / gitConfigName('DSL User')
            node / gitConfigEmail('jenkins-dsl@newtech.academy')
        }
    }

    // 트리거 - 몇 번이나 구축할 것인가
    triggers {
        scm('H/5 * * * *')  // scm에서 5분마다 가져와라
    }

    // 래퍼 - 사전 필요한 환경을 입력
    wrapers {
        nodejs('nodejs')    // NodeJS 설치
        // 플러그인 설치 및 확인: Manage Jenkins -> Configure Tools -> NodeJS Installations -> Name
    }

    // 단계
    steps {
        shell("npm install")
    }
}
```

## 젠킨스에 DSL 플러그인 사전 설치
- Manage Jenkins -> Configure Tools -> NodeJS Installations -> Name

## 스크립트 설치를 승인해야한다.
- In-process Script Approval

# 젠킨스 Job DSL API
![dsl_apis](dsl_apis.png)
- <https://jenkinsci.github.io/job-dsl-plugin/>
- 해당 웹 사이트를 사용하여, 사용 가능한 메서드와 플러그인을 찾을 수 있다.


