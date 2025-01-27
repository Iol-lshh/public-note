# docker
## docker registry
-  [Docker Hub](https://hub.docker.com)
    - public repository
    - find base images for many technologies or OS
- Amazon Elastic Container Registry
    - private repository
    - public repository [Amazon ECR public Gallery](https://gallery.ecr.aws)

# 컨테이너 관리 서비스
- Elastic Container Service
- Elastic Kubernetes Service
- Fargate
- Elastic Container Registry


# ECS
- 도커파일 컨테이너로 AWS에서 실행한다는 것은, ECS 클러스터에서 ECS 태스크를 실행한다는 것
- ECS의 시작 유형은 여러가지이다.

## EC2 시작 유형
- 인프라를 직접 프로비저닝 및 관리해야 한다.
- ECS 클러스터는 여러 EC2 인스턴스로 구성된다.
    - 각 인스턴스가 ECS 에이전트를 실행해야 한다.
        - ECS 서비스와 지정된 ECS 클러스터에 각각의 EC2 인스턴스를 등록해준다.
    - ECS 태스크를 시작/중지시, 컨테이너가 자동으로 배치된다.
    - 미리 프로비저닝한 EC2 인스턴스들에 도커 컨테이너가 배포되는 것                
![ecs_start_with_ec2](ecs_start_with_ec2.PNG)

## Fargate 시작 유형
- 프로비저닝할 필요가 없다.
    - 관리할 EC2 인스턴스가 없다.
    - 서버리스!
        - 관리할 서버가 없다. 실제 기반에는 서버가 있긴하다.
- ECS 태스크만 정의하면, CPU와 RAM 요구사항을 토대로 ECS 태스크를 실행한다.
- 계정의 백엔드에서 실행 위치를 확인하거나, EC2 인스턴스를 만들 필요 없이 간단하게 실행한다.
    - 확장시, 태스크 수만 늘리면 된다.
        - EC2 인스턴스 관리가 필요 없다.
![ecs_start_with_fargate](ecs_start_with_fargate.PNG)

# EC2 시작 유형 고려할 부분
## IAM Roles for ECS
- EC2 이용시,
    - EC2 Instance Profile
        - used by the ECS agent
        - ECS 서비스에 인스턴스를 복원하는 API 호출을 할 수 있다.
        - CloudWatch Logs에 컨테이너 로그를 전송할 수 있다.
        - ECR에서 도커 이미지를 가져오는 API 호출(pull)을 할 수 있다.
        - 시크릿 매니저, SSM Parameter Store에서 민감한 데이터를 참조할 수 있다.
- Fargate도 동일하다
    - ECS Task Role
        - 태스크별로 특별한 role을 줄 수 있다.
        - 서로 다른 role을 주는 이유는, 각 서비스가 서로 다른 서비스에 연결할 수 있기 때문
        - 태스크 Role은 ECS 태스크 정의에서 작성된다.
![ecs_role_with_ec2](ecs_role_with_ec2.PNG)
- EC2 인스턴스 프로필과 ECS 태스크 Role의 구분은 반드시 필요하다.

## Load Balancer Integration
- Fargate도 동일하다.
- <https://aws.amazon.com/ko/elasticloadbalancing/>
- Application Load Balancer
    - 여러개의 태스크가 있고, HTTP/HTTPS 엔드포인트 노출시, ALB를 클러스터 앞에서 실행한다.
![ALB](ALB.jpeg)
- Network Load Balancer
    - 높은 throughput이나 성능이 요구될때
    - AWS PrivateLink 사용시 권장
- Elastic Load Balancer
    - 이전 세대의 로드밸런서도 사용할 수 있지만, 고급 기능이 없고, Fargate는 연결 불가능하다.
    - 권장되지 않는다.
    - Fargate도 사용 가능한 ALB가 권장된다.

## Data Volumes (Elastic File System)
- 데이터 공유를 위해, ECS 태스크에 파일 시스템을 마운트
- EFS
    - 네트워크 파일 시스템
    - 서버리스
        - 사용량 기반 요금 청구
    - EC2, Fargate 모두 호환
    - ECS 태스크에 파일 시스템을 바로 마운트할 수 있다.
    - 파일 시스템에 연결되어 있다면, 실행중인 태스크에서 데이터를 공유하고, 파일 시스템을 통해 서로 통신 가능하다.
![EFS](EFS.jpeg)
- Fargate + EFS는 서버리스 방식의 최상의 조합이다.
- Amazon S3는 ECS 태스크에 파일 시스템으로 마운트할 수 없다.

## CI/CD
- [CI/CD 예제](../../cicd/git/CICD_ECS/cicd_action_aws.md)
