# 암호 잘못 입력했을때 캐시 지우기

- 키체인 접근으로 들어와서 CodeCommit를 검색하면 이전에 사용했던 CodeCommit에 대한 기록이 그대로 남아있습니다.
- 이 CodeCommit 암호를 삭제합니다.
```sh
git config --global credential.helper "!aws codecommit credential-helper $@"
git config --global credential.UseHttpPath true
```


git configuration를 설정합니다.
```js
git config --system -l
credential.helper=osxkeychain
```

