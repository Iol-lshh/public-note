# terraform vs others
- 테라폼은 인프라 프로비저닝 자동화를 목표
    - AWS, Azure 등 API를 제공하는 곳에 사용
- Ansible, Chef, Puppet, Saltstack은 소프트웨어 설치와 구성 자동화에 초점
    - 머신의 일정 상태로 compliance 유지를 목표
    - 머신 자체를 자동화하고 싶다면, Ansible 또는 Chef 사용
    - 테라폼으로 인프라를 프로비저닝 후, 소프트웨어를 설치하기 위해 Ansible 자동화 소프트웨어와 함께 사용을 추천
- 테라폼으로 하드웨어를 스핀 업하여 하드웨어를 사용 가능한 상태로 만들고, 
    - 앤서블을 이용하여 머신에 소프트웨어를 설치하고 구성

# 테라폼 설치
- [테라폼 공식 홈페이지 설치](https://developer.hashicorp.com/terraform/install?product_intent=terraform)
    - 운영체제에 맞는 압축 파일 다운로드
    
## 환경 설정
```shell
# zip 다운로드, 및 압축 해제
mkdir terraform
unzip unzip ../Downloads/<terraform_적절한_버전과_아키텍처의_압축파일.zip>
# 환경 설정
export PATH=/Users/<유저명>/terraform/:$PATH    

# 윈도우
set PATH=%PATH%;C:\terraform
```


