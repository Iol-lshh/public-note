# 명령어
## SET
```shell
$ SET message 'Hi there'
"OK"
```
- key message로 문자열 값을 저장

## GET
```shell
$ GET message
"Hi there!"
```
- key message로 문자열 값을 호출

### 지원하는 자료구조
![redis_datastructures](redis_datastructures.jpeg)
- String
- List
- Hash
- Set
- Sorted Set
- Bitemap
- Hyperloglog
- JSON
- Index

## 공식 문서
- 명령어 공식 문서<redis.io/commands>

## 명령어 뜯어보기
![command_format](command_format.jpeg)
- 대문자 단어는 키워드 (예약어)
- 소문자 단어는 개발자가 원하는 값
- 대괄호 단어는 선택사항
- `|`는 OR

---
- SET
- MSET (Mutiple SET)

- GET
- MGET (Mutiple GET)

