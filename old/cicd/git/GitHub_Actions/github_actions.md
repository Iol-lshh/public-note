
# GitHub Actions
- 깃허브(GitHub)에서 제공하는 CI/CD를 위한 서비스
- 어떤 이벤트(event)가 발생했을 때 특정 작업이 일어나게 하거나, 주기적으로 어떤 작업들을 반복해서 실행 할 수 있다.

## 구조
- [Workflow](#workflows)
    - 조건(on)
    - Jobs
        - Steps
- Actions
### 참조
- [구문 공식 문서](https://docs.github.com/ko/actions/using-workflows/workflow-syntax-for-github-actions#onevent_nametypes)

# Workflows
- 작업 흐름
    - 자동화한 과정
- `.github/workflows` 위치의 YAML 파일
- 워크플로우 파일은 조건인 [on](#조건)과 작업할 [jobs](#jobs)로 나뉜다.
# 조건
- 언제 이 workflows가 실행되어야할지 정의한다.
- 두가지로 나뉜다.
    1. 브랜치 이벤트 트리거 [push](#이벤트-트리거)
    2. 지정된 스케쥴에 작동하게 하는 [schedule](#스케쥴)
- `on.<event_name>`

### 이벤트 트리거
- `on.push.<branches|tags|branches-ignore|tags-ignore>`
- `on.<push|pull_request|pull_request_target>.<paths|paths-ignore>`
    - 지정한 브랜치에 push 이벤트가 발생할 때 마다 워크플로우를 실행
```yml
on: 
    push:
        branches: [main]
jobs:
```

### 스케쥴
- `on.schedule`
    - 지정한 schedule에 실행
```yml
on: 
    schedule:
        - cron: "0 0 * * *"
jobs:
```

# Jobs
- `jobs.<job_id>`
- 독립된 가상 머신(machine) 또는 컨테이너(container)에서 돌아가는 하나의 처리 단위
- 하나의 워크플로우는 **한 개 이상**의 Job으로 이루어져있다.
    - 모든 작업은 동시에 시작된다.
    - 의존 관계를 설정하여, 순서를 제어할 수 있다.
    - Map의 형태
- 각 Job은 서로 다른 CI 서버에서 실행된다.
    - 동일 Job의 step들은 같은 CI 서버에서 실행된다.
## runs-on
- 실행 환경 지정
- 필수 속성
## steps
- 작업의 순차적인 명령들
    - 시퀀스(배열) 형태이다.
- command, script, [action](#actions)을 실행한다.
    - run
        - command, script 실행 명령 속성
    - uses
        - action 실행 명령 속성

```yml
jobs:
  job1:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm install
      - run: npm test
  job2:
    # job2에 대한 세부 내용
  job3:
    # job3에 대한 세부 내용
```

# Jobs 작성방법
## 작업 실행순서 제어
- needs를 통해 의존성 추가
```yml
name: Our Jobs
on: push
jobs:
  job1:
    runs-on: ubuntu-latest
    steps:
      - run: echo ${{ github.job }}
  job2:
    runs-on: ubuntu-latest
    needs: job1
    steps:
      - run: echo ${{ github.job }}
  job3:
    runs-on: ubuntu-latest
    needs: [job1, job2]
    steps:
      - run: echo ${{ github.job }}
```
### 의존된 job에서 출력값 전달
- outputs에 명시된 값을, needs로 받는다.
```yml
name: Our Jobs
on: push
jobs:
  job1:
    runs-on: ubuntu-latest
    steps:
      - id: step1
        run: echo "word=GitHub" >> $GITHUB_OUTPUT
      - id: step2
        run: echo "word=Actions" >> $GITHUB_OUTPUT
    outputs:
      word1: ${{ steps.step1.outputs.word }}
      word2: ${{ steps.step2.outputs.word }}
  job2:
    runs-on: ubuntu-latest
    needs: job1
    steps:
      - run: echo "${{ needs.job1.outputs.word1 }}"
      - run: echo "${{ needs.job1.outputs.word2 }}"
```
- `word1: steps.step1.outputs.word` >> `needs.job1.outputs.word1`

## 동일 Job을 여러 실행환경에서 실행
```yml
name: Our Jobs
on: push
jobs:
#   date1:
#     runs-on: ubuntu-latest
#     steps:
#       - run: date
#   date2:
#     runs-on: windows-latest
#     steps:
#       - run: date
#   date3:
#     runs-on: macos-latest
#     steps:
#       - run: date
    date:
        strategy:
            matrix:
                os:
                    - ubuntu-latest
                    - windows-latest
                    - macos-latest
            runs-on: ${{ matrix.os }}
            steps:
                - run: date
```

## 선택적 작업 실행
- if
```yml
name: Our Jobs
on: push
jobs:
  echo:
    runs-on: ubuntu-latest
    steps:
      - run: echo 'Hello!'
  echo_if:
    runs-on: ubuntu-latest
    if: github.ref_name == 'main'
    steps:
      - run: echo 'Hello, Main!'
  skip_ci:
    runs-on: ubuntu-latest
    if: contains(github.event.head_commit.message, 'skip ci')
    steps:
      - run: echo 'Hello, Skip CI!'
```

## 작업내용을 마크다운으로 표시하기
- $GITHUB_STEP_SUMMARY 환경파일에 저장하면, 잡 요약이 출력된다.
    - `echo "string" >>  $GITHUB_STEP_SUMMARY`
    - bash 리다이렉션이다.
    - 잡 요약은 덮어쓰기가 되지 않는다.
```yml
name: Our Jobs
on: push
jobs:
  todos:
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo "## 할일 목록" >> $GITHUB_STEP_SUMMARY
          echo "- 자기" >> $GITHUB_STEP_SUMMARY
          echo "- 놀기" >> $GITHUB_STEP_SUMMARY
          echo "- 먹기" >> $GITHUB_STEP_SUMMARY
```


# Actions
- 재사용하는 Step을 위한 공유 메커니즘
    - 코드 저장소 범위 내, 워크플로우들에서 사용 가능
    - 공개 코드 저장소를 통해, 액션 공유 가능
        - GitHub 상의 모든 코드 저장소에서 사용 가능
        - [깃헙 마켓플레이스](https://github.com/marketplace?type=actions)

### action.yml
```yml
name: Calc Action
inputs:
  x:
    default: 0
  y:
    default: 0
outputs:
  plus:
    value: ${{ steps.plus.outputs.result }}
  minus:
    value: ${{ steps.minus.outputs.result }}
runs:
  using: "composite"
  steps:
    - run: echo "Hi, I'm a calculator action!"
      shell: bash
    - run: echo "x = ${{ inputs.x }}, y = ${{ inputs.y }}"
      shell: bash

    - id: plus
      run: echo "result=$((${{ inputs.x }} + ${{ inputs.y }}))" >> $GITHUB_OUTPUT
      shell: bash
    - id: minus
      run: echo "result=$((${{ inputs.x }} - ${{ inputs.y }}))" >> $GITHUB_OUTPUT
      shell: bash
```
- description: 액션 설명
- inputs: 입력값
- outputs: 반환값
    - `steps.<step_id>.outputs.<output_name>`

### .github/workflows/main.yml
```yml
name: Our Workflow
on: push
jobs:
  calculate:
    runs-on: ubuntu-latest
    steps:
      - id: calc
        uses: DaleSchool/calc-action@v1
        with:
          x: 12
          y: 3
      - name: print results
        run: |
          echo "x + y = ${{ steps.calc.outputs.plus }}"
          echo "x - y = ${{ steps.calc.outputs.minus }}"
```
- 액션: 소유자/저장소@태그
- with: 입력값




# 참조
- <https://www.daleseo.com/github-actions-basics/>


