# Why redis is fast?
1. all data is sotred in memory
    - 레디스는 메모리에만 데이터를 저장하기 때문에 빠르다.
2. Data is organized in simple data structures
    - 레디스는 매우 간단한 데이터 구조를 가진다.
![simple_data_structure](simple_data_structure.jpeg)
    - 연결리스트, 정렬 세트, 해시 맵 같은 고전적인 자료 구조로 관리된다.
    - 간단한 구조이기 때문에, 개발자가 메모리에서 정보를 어떻게 관리하는지 정확하게 파악할 수 있다.
    - 어떻게 효율적인 쿼리할지 이해가 쉽다.
3. Redis has a simple feature set
    - 레디스는 단순하다
        - 스키마도 강제하지 않고
        - 트리거도 없고
        - 외래키도 없고
        - 유니크 제한도 없고
        - SQL을 지원하지도 않고
        - 트랜잭션과 롤백을 지원하지도 않는다

## goal
- 이런 단순한 구조의 레디스로 어떻게 작업해야할지 알아야 한다. 

# setup
1. install redis
    - redis cloud인 redis.com에 인스턴스 생성
    - 설치하고, 로컬에서 실행

2. run redis commands manually
    - rbook.cloud 사용
    - 로컬에서 rbook 사용
    - Redis-CLI 사용

## local
1. node.js 설치
2. npx rbook
3. http://localhost:3050

