
- [세션 wikipedia](https://en.wikipedia.org/wiki/Session_(computer_science))

# **세션** = **"논리적 연결"**

# OSI 7 layer
- 물리Physical
    - 장비. 허브 리피터
    - 비트, 물리 이동
- 데이터링크DataLink 
    - 장비. 스위치 브리지
    - 흐름 제어
- 네트워크Network 
    - 장비. 라우터 L3스위치
    - 라우팅, IP
- 전송Transport
    - L4 스위치
    - TCP, UDP
        - 가상 회선, 소켓 통신
- 세션Session
    - 프로세스 간 논리적 연결
- 표현Presentation
    - 압축, 암호화
- 응용Application
    - L7 스위치
    - HTTP, FTP

## Session
- **세션** = **"논리적 연결"**
- 상태 저장
- 제한된 시간의 양방향 링크
    - 단방향 전송은 세션이라고 하지 않는다.
        - 세션은 양방향적인 통신을 의미하며, 서로 데이터를 주고받을 수 있는 연결된 상태를 말합니다. 
        - 단방향 전송은 한쪽에서만 데이터를 보내고, 상대방으로부터 응답이나 확인을 받지 못하는 방식입니다. 
        - 따라서 세션 개념은 양방향적인 데이터 흐름과 연결 상태를 전제로 하기 때문에 단방향 전송만으로는 세션을 구성할 수 없습니다.


## L7 응용 계층 예시:
- [HTTP](https://en.wikipedia.org/wiki/HTTP) 세션: 개별 방문자와 정보를 연결
- telnet 원격 로그인 세션: 컴퓨터에 원격 연결

## L5 세션 계층 예시:
- SIP ([Session Initiation Protocol](https://en.wikipedia.org/wiki/Session_Initiation_Protocol)) 기반 인터넷 전화 통화

## L4 전송 계층 예시:
- TCP 세션
    - [TCP VC](https://en.wikipedia.org/wiki/Virtual_circuit)(virtual circuit - 가상 회선)
    - TCP 연결
    - [TCP 소켓](https://en.wikipedia.org/wiki/Network_socket)
    - [API](https://en.wikipedia.org/wiki/API)(application programming interface) 컴퓨터 간 연결. 소프트웨어 인터페이스
- 컴퓨터 간에 안정적이고 신뢰성 있는 데이터 흐름을 제공합니다.



