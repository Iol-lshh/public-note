
# VSCode Code-Server
- [code-serer 깃헙](https://github.com/coder/code-server)
- [wsl을 사용한 예제](https://tong9433.github.io/blog/002#/)


## [도커로 구성한 예제](https://velog.io/@shin6949/code-server-Docker%EB%A1%9C-%EA%B5%AC%EC%84%B1%ED%95%98%EA%B8%B0)
- [code-server 공식 이미지](https://hub.docker.com/r/linuxserver/code-server)

- 컴포즈 파일
```yaml
version: "3.1"
services:
  code-server:
    image: linuxserver/code-server:latest
    container_name: code-server
    # stop 상태가 되지 않는 이상 재시작
    restart: always
    ports:
      - "8443:8443"
    environment:
      # Container 내의 시간대를 대한민국으로 설정
      TZ: Asia/Seoul
      # code-space에 진입할 때 비밀번호를 입력하게 할려면 이 내용을 설정
      PASSWORD: <PASSWORD>
      # 기본 Workspace 위치 지정 (Container 내 경로로)
      DEFAULT_WORKSPACE: /config/workspace
    volumes:
      # VSCode의 설정이 저장될 위치 -> 컨테이너가 재시작 되어도 설정이 초기화 되지 않도록 조치
      - codeserver-config:/config
      # Workspace을 Host와 연결
      - /home/lshh/IdeaProjects:/config/workspace
      
volumes:
  codeserver-config:
```


