# Terraform HCL
- HasiCorp Configuration Language

# 기초 syntex
1. 변수 variable
2. 공급자 provider
3. 리소스 resource

# variable
- 테라폼 변수 이용시,
    - 리소스 생성 전에 변수를 생성한다.
```python
# main.tf

variable "myvar"{
    type = "string"
    default = "hello terraform"
}
```
- 확인
```shell
terraform console
> var.myvar
# hello terraform
> "${var.myvar}"
# hello terraform
> exit
```
- 변수 타입 종류
    - 단순 변수 타입
        - string, number, bool
    - 객체 변수 타입
        - list, set, map, object, tuple
        - 가장 많이 쓰이는 것은 list와 map

## list
- List(type)
- 항상 오름차순 인덱스
```python
variable "mylist"{
    type = "list"
    default = [1,2,3]
}
```
- 확인
```shell
terraform console
> var.mylist
# [
#     1,
#     2,
#     3,
# ]
> var.mylist[0]
# 1
> element(var.mylist, 0)
# 1
> slice(var.mylist, 0, 2)
# [
#     1,
#     2,
# ]
```

## map
- Map(type)
```python
variable "mymap"{
    type = "map(string)"
    default = {
        mykey = "my value"
    }
}
```
- 확인
```shell
terraform console
> var.mymap
# {
#     "mykey" = "my value"
# }
> var.mymap["mykey"]
# my value
> "${var.mymap["mykey"]}"
# my value
```

## set
- Set(type)
- 리스트와 형식이 같으나, 순서를 가지지 않으며, 고유값을 가진다.

## object
- Object({<ATTR NAME> = <TYPE>, ...})
- 각 요소는 다른 타입을 가질 수 있다.
```python
{
    firstname="hong"
    birthmonth=4
    birthday=9
}
```

## tuple
- Tuple([<TYPE>, ...])
- 리스트와 같지만, 각 요소는 다른 타입을 가질 수 있다.
    - object와 map처럼
```python
[0, "stirng", false]
```

## 참고
- 타입을 명시 하지 않아도, 타입 체크를 한다.


# resource
- 리소스 사용시, provider 공급자도 지정해줘야 한다.
```python
# resource.tf

# aws 예
provider "aws" {
}

variable "AWS_REGION" { # terraform.tfvars 파일을 이용해서 데이터를 정해줄 수 있다.
    type = string
}

variable "AMIS" {
    type = map(string)
    default = {
        ap-northeast-2 = "my ami" # todo
    }
}

resource "aws_instnace" "example" { # "<리소스 타입>" "<리소스 이름>"
    ami = var.AMIS[var.AWS_REGION]  # "${var.AMIS[var.AWS_REGION]}"
    instance_type = "t2.micro"
}


resource "aws_instnace" "example2" { 
    ami = var.AMIS[var.AWS_REGION]  
    instance_type = "t2.small"
}
```

```python
# terraform.tfvars
AWS_REGION="ap-northeast-2"
```

## provider를 위해, 공급자 플러그인을 받아야 한다
```shell
terraform init
```
- 공급자 변경할 때 마다,
- 모듈이나 플러그인 사용시,
- terraform init을 실행해야 한다.
    - 백엔드 초기화
    - 공급자 플러그인 초기화
- 모든 버전의 provider는 자체 깃허브 레포지토리가 있다.
    - 특정 버전 사용시,
```python
provider "aws" {
    version = "~> 2.33"
}
```

----------------------------
## provider.tf
```python
# provider.tf
provider "aws" {
    access_key = "${var.AWS_ACCESS_KEY}"
    secret_key = "${var.AWS_SECRET_KEY}"
    region = "${var.AWS_REGION}"
}

# vars.tf
variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
    default = "ap-northeast-2"
}
variable "AMIS" {
    type = "map"
    default = {
        ap-northeast-2 = "ami-065449c7a548b9e29"
        us-east-1 = "ami-13be557e"
    }
}

# terraform.tfvars
AWS_ACCESS_KEY = ""
AWS_SECRET_KEY = ""
AWS_REGION = "ap-northeast-2"

# instance.tf
resource "aws_instance" "example" {
    ami = "${lookup(var.AMIS, var.AWS_REGION)}"
    instance_type = "t2.micro"
}
```
- `terraform.tfvars` 실제 변수가 들어가며, git.ignore로 관리
- `instance.tf` 공급자를 AWS 에서 별도 파일로 옮겨 주는 역할만 하며, 변화가 없는 파일

