# aws에 인스턴스 스핀 업하기

## 순서
1. AWS account
2. IAM admin user
3. t2.micro 인스턴스 생성용 terraform file 작성
4. 테라폼 실행

## IAM에게 줘야할 AWS 권한 정책
- AdministratorAccess

## terraform file 작성
- [예제](old/infra/terraform/lecture/01_first-steps/instance.tf)

```python
provider "aws" {
  access_key = "<ACCESS_KEY_HERE>"
  secret_key = "<SECRET_KEY_HERE>"
  region     = "ap-northeast-2"
}

resource "aws_instance" "example" {
  ami           = "ami-065449c7a548b9e29"
  instance_type = "t2.micro"
}
```
- [ami 정보 조회](https://cloud-images.ubuntu.com/locator/ec2/)
- 전부 작성 후, `terraform init`
    - 공급자 aws 플러그인 다운로드

## terraform 실행
```shell
# terraform aws 인스턴스 실행
terraform apply

# 모든 해당 terrafrom aws 인스턴스 제거. 프로덕션에서는 절대 사용하지 않도록 한다. 전부 사라진다..
terraform destroy

# 테라폼 파일을 확인. 인프라에 직접 적용하지 않고, 어떤 계획이 있는지 확인
terraform plan


## out.terraform에 계획을 저장하고, 저장한 계획 실행하기
terraform plan -out out.terraform
terraform apply out.terraform
```
- `terraform apply`는 
    - `terraform plan -out file; terraform apply file; rm file`의 단축키이다.
- 항상 plan과 apply를 나눠서, 인프라에 반영될 적용 사항들, 변경 사항들을 확인하도록 한다.

---------------------

# 소프트웨어 프로비저닝
1. build own custom AMI
    - 소프트웨어를 이미지로 번들링
        - Packer
2. 표준 AMI를 부팅
    - 필요한 소프트웨어를 설치
        - 파일 업로드
        - 원격 파일 실행과 스크립트
        - 셰프, 퍼펫, 앤서블 같은 자동화 툴 사용
    - 테라폼을 먼저 실행 후, 앤서블을 실행


# provisioner
## 파일 업로드 프로비저닝
- 프로비저너 파일을 aws 인스턴스 리소스에 추가
```python
# instance.tf
resource "aws_instance" "example" {
    ami = "${lookup(var.AMIS, var.AWS_REGION)}"
    instance_type = "t2.micro"

    provisioner "file" {
        source = "app.conf"
        destination = "/etc/myapp.conf"
    }
}
```

## 원격 실행
- remote-exec
- 스크립트를 실행하기 위함
    - SSH (리눅스 호스트), WinRM (윈도우 호스트)
```python
# instance.tf
resource "aws_instance" "example" {
    ami = "${lookup(var.AMIS, var.AWS_REGION)}"
    instance_type = "t2.micro"

    provisioner "file" {
        source = "script.sh"
        destination = "/opt/script.sh"
        connection {
            user = "${var.instance_username}"
            password = "${var.instance_password}"
        }
    }
}
```

### aws는 암호 대신, SSH 키 페어를 사용
```python
# instance.tf
resource "aws_key_pair" "edward-key" {
    key_name = "mykey"
    public_key = "ssh-rsa <my-public-key>"
}
resource "aws_instance" "example" {
    ami = "${lookup(var.AMIS, var.AWS_REGION)}"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.mykey.key_name}"

    provisioner "file" {
        source = "script.sh"
        destination = "/opt/script.sh"
        connection {
            user = "${var.instance_username}"
            password = "${file(${var.path_to_private_key})}"
        }
    }
    provisioner "remote-exec" {
        inline = [
            "chmod +x /opt/script.sh",
            "/opt/script.sh arguments"
        ]
    }
}
```
- "file" 프로비저너는 script.sh를 업로드
    - 공개키를 참조
- remote-exec를 위해, 실행 가능하도록, x 권한을 추가하고 실행


