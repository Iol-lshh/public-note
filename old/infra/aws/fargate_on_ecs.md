# ECS
- Elastic Container Service
    - vs Elastic Kubernetes Service

# Fargate
- AWS Fargate는 Amazon ECS와 함께 컨테이너를 실행하는 데 사용할 수 있는 기술
    - 가상 머신 클러스터를 프로비저닝, 구성 또는 확장을 지원한다.
    - 서버 유형을 선택하거나, 클러스터 확장 시기를 결정하거나, 클러스터 패킹을 최적화할 필요가 없다.
    - 작업과 서비스를 실행할 때 애플리케이션을 컨테이너에 패키징하고, CPU 및 메모리 요구 사항을 지정하고, 네트워킹 및 IAM 정책을 정의하고, 애플리케이션을 시작하면 된다.
        - 자체 격리 경계가 있으며 기본 커널, CPU 리소스, 메모리 리소스 또는 탄력적 네트워크 인터페이스를 다른 작업과 공유하지 않는다.
        
- [요금 정책](https://aws.amazon.com/ko/fargate/pricing/)

# ECS 단위
## Task Definition
- Task에 대한 정의
- Task에 대한 CPU, memory, 실행될 컨테이너에 대한 image 정의 등을 할 수 있다.
    - 프로그램 프로세스의 관계로 빗대어 봤을때, 프로그램에 해당

## Task
- Task Definition에 대한 인스턴스
    - 프로그램 프로세스의 관계로 빗대어 봤을때, 프로세스에 해당
- Task는 다음 종류가 될 수 있다.
    1. EC2
    2. Fargate
- Task는 하나 이상의 컨테이너를 포함한다.

## Service
- Task Definition에 일대일로 대응하는 단위
    - 동일한 Definition에 대한 인스턴스들을 가리킴
    - 하나의 Task Definition으로 몇개의 Task를 띄울지 설정할 수 있다.

## Cluster
- 가상의 공간. 실제 여러 Cluster instance로 분산 환경일 수 있다.
- Cluster 내부의 태스크와 서비스는 네트워킹 정보와 인프라 설정(fargate or EC2)을 공유한다.

# AWS CLI를 이용한 Fargate Linux 태스크
- [자습서: AWS CLI를 사용하여 Fargate Linux 태스크로 클러스터 생성](https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/userguide/ECS_AWSCLI_Fargate.html#ECS_AWSCLI_Fargate_create_cluster)
## 1. 클러스터 생성
- `aws ecs create-cluster --cluster-name fargate-cluster`
    - fargate-cluster 이름으로 클러스터 생성

## 2. Task Definition by JSON
- [파라미터 리스트](https://docs.aws.amazon.com/ko_kr/AmazonECS/latest/userguide/task_definition_parameters.html)
```json
{
    "family": "hhp",
    // 시작 유형: EC2 | FARGATE | EXTERNAL
    "requiresCompatibilities": [
        "FARGATE"
    ],
    // 네트워크 모드: 태스크의 컨테이너에 사용할 Docker 네트워킹 모드. Fargate에서 호스팅되는 Amazon ECS 태스크의 경우, awsvpc 네트워크 모드가 필요
    "networkMode": "awsvpc",
    "cpu": "256",
    "memory": "512",
    "containerDefinitions": [
        {
            "name": "",
            "image": "",
            "essential": true,
            "portMappings": [
                {
                    "containerPort": 80,
                    "hostPort": 80
                }
            ],
            // 컨테이너로 전달되는 진입점.  Docker 원격 API의 컨테이너 생성 섹션에 있는 Entrypoint와 docker run에 대한 --entrypoint 옵션에 매핑
            "entryPoint": [
                "sh",
                "-c"
            ],
            // 컨테이너로 전달되는 명령.  docker run의 COMMAND 파라미터로 매핑
            "command": [
                "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
            ],
            "environment": [
                {"name" : "string", "value" : "string"},
                {"name" : "string", "value" : "string"}
            ],
            "secrets": [
                {
                    //AWS Secrets Manager 암호의 전체 ARN 또는 AWS Systems Manager 파라미터 스토어
                    "name": "environment_variable_name",
                    "valueFrom": "arn:aws:ssm:region:aws_account_id:parameter/parameter_name"
                }
            ],
            "dependsOn": [
                {
                    "containerName": "string",
                    // 종속성 조건: START | COMPLELTE | SUCCESS | HEALTHY
                    "condition": "string"
                }
            ]
        }
    ],
}
```
- 작업 정의에 작성한 JSON 파일을 사용
    - `aws ecs register-task-definition --cli-input-json file://$HOME/tasks/fargate-task.json`

## 3. 서비스 생성
### 프라이빗 서브넷
- `aws ecs create-service --cluster fargate-cluster --service-name fargate-service --task-definition sample-fargate:1 --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[subnet-abcd1234],securityGroups=[sg-abcd1234]}" --enable-execute-command`
### 퍼블릭 서브넷
- `aws ecs create-service --cluster fargate-cluster --service-name fargate-service --task-definition sample-fargate:1 --desired-count 1 --launch-type "FARGATE" --network-configuration "awsvpcConfiguration={subnets=[subnet-abcd1234],securityGroups=[sg-abcd1234],assignPublicIp=ENABLED}"`

## 4. 삭제
### 서비스 삭제
- `aws ecs delete-service --cluster fargate-cluster --service fargate-service --force`
### 클러스터 삭제
- `aws ecs delete-cluster --cluster fargate-cluster`


