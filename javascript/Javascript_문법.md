---
title: JavaScript 문법
date: 2023-03-02
description: JavaScript 문법 정리
category:
  - javascript
---

- [1. 변수](#1-변수)
  - [1.1 const와 let](#11-const와-let)
    - [1.1.1 const](#111-const)
    - [1.1.2 let](#112-let)
  - [1.2 호이스팅](#12-호이스팅)
- [2. 불변성](#2-불변성)
  - [2.1 배열](#21-배열)
    - [2.1.1 filter](#211-filter)
    - [2.1.2 map](#212-map)
    - [2.1.3 reduce](#213-reduce)
    - [2.1.4 전개연산자 (...)](#214-전개연산자)
- [3. Null 유효성 관리](#3-null-유효성-관리)
  - [3.1 논리OR(||) VS 널병합연산자(??)](#31-논리or-vs-널병합연산자)
  - [3.2 옵셔널 체이닝(.?)](#32-옵셔널-체이닝)
- [4. 객체](#4-객체)
  - [4.1 프로퍼티](#41-프로퍼티)
    - [4.1.1 프로퍼티 축약 표현](#411-프로퍼티-축약-표현)
    - [4.1.2 계산된 프로퍼티 이름](#412-계산된-프로퍼티-이름)
  - [4.2 메서드](#42-메서드)
    - [4.2.1 메서드 축약 표현](#421-메서드-축약-표현)
- [5. 함수](#5-함수)
  - [5.1 this](#51-this)
    - [5.1.1 일반 function](#511-일반-function)
    - [5.1.2 화살표 함수](#512-화살표-함수)
    - [5.1.3 생성자 함수(new)에 의한 인스턴스의 function](#513-생성자-함수new에-의한-인스턴스의-function)
  - [5.2 함수 호이스팅 방지](#52-함수-호이스팅-방지)
  - [5.3 책임 분리](#53-책임-분리)
    - [5.3.1 데이터 호출 함수](#531-데이터-호출-함수)
    - [5.3.2 비즈니스 로직 함수](#532-비즈니스-로직-함수)
    - [5.3.3 프레젠테이션 로직 함수](#533-프레젠테이션-로직-함수)
  - [5.4 매개변수](#54-매개변수)
    - [5.4.1 default 매개변수](#541-default-매개변수)
    - [5.4.2 구조분해 할당](#542-구조분해-할당)
    - [5.4.3 나머지 매개변수 (...)](#543-나머지-매개변수)
- [6. 비동기](#6-비동기)
  - [6.1 프로미스 처리: 체이닝 함수 then](#61-프로미스-처리-체이닝-함수-then)
  - [6.2 async await](#62-async-await)
  - [6.3 중첩된 비동기 처리](#63-중첩된-비동기-처리)
    - [6.3.1 for ... of ... 순서대로 비동기 처리](#631-for--of--순서대로-비동기-처리)
    - [6.3.2 reduce 함수](#632-reduce-함수)
    - [6.3.3 Promise.all( ) 비동기 처리](#633-promiseall--비동기-처리)
  - [6.4 쓰로틀링과 디바운스 처리](#64-쓰로틀링과-디바운스-처리)
    - [6.4.1 디바운스(Debouncing)](#641-디바운스debouncing)
    - [6.4.2 쓰로틀링(Throttling)](#642-쓰로틀링throttling)

## 1. 변수

- 자바스크립트는 동적 타입
- Call By Sharing

### 1.1 const와 let

#### 1.1.1 const

- 변수는 기본적으로 `const`로 정의한다.

```javascript
const foo;
```

#### 1.1.2 let

- 반복의 인자로써 변수는 `let`로 정의한다.

```javascript
const fooArr = [1, 2, 3, 4];

for (let idx in fooArr) {
  console.log(fooArr[idx]);
}
```

### 1.2 호이스팅

- 변수(함수 포함)의 호이스팅에 주의하여 작성한다.
- 변수들의 선언을, 사용되는 로직과 가까이하여, 쉐도잉을 방지한다.
- `var` 사용을 지양한다.
- 함수 선언시, `const`로 정의한 변수에 할당시켜 사용한다. 

---

## 2. 불변성

- 모든 객체는 불변성 유지를 지향한다.
- 원본 데이터의 객체는, 다시 새 데이터를 입력받아서만 수정한다.

### 2.1 배열

- 속성 배열의 값이 바뀌었을때, deep copy를 통한 재할당을 지향한다.
- filter, map, reduce 함수 사용을 지향한다.
- 전개연산자 `...` 사용을 지향한다.

#### 2.1.1 filter

```javascript
const fooArr = [1,2,3,4];
const evenArr = fooArr.filter(e => e % 2 === 0);
```

#### 2.1.2 map

```javascript
const fooArr = [1,2,3,4];
const doubleArr = fooArr.map(e => e * 2);
```

#### 2.1.3 reduce

```javascript
const fooArr = [1,2,3,4];
const sum = fooArr.reduce((acc, e) => acc + e, 0);
```

#### 2.1.4 전개연산자 (`...`)

```javascript
const foo = {
  barArr: [1,2,3,4],
};
// put 5
foo.barArr = [...foo.barArr, 5];
// pop 5
foo.barArr = [...foo.barArr.pop()];
```

---

## 3. Null 유효성 관리

- null과 undefined 관리를 지향한다.
- 논리OR(`||`) 와 널병합연산자(`??`)를 적절한 곳에 사용한다.
- 옵셔널 체이닝(`.?`) 활용을 지향한다.

### 3.1 논리OR(`||`) VS 널병합연산자(`??`)

```javascript
// 빈 문자열 할당 (논리 평가시 false)
let myText = '';

// # 논리OR
let notFalsyText = myText || 'Hello world';
console.log(notFalsyText); // Hello world

// # 널병합연산자
let preservingFalsy = myText ?? 'Hi neighborhood';
console.log(preservingFalsy); // '' -> undefined나 null이 아니므로!
```

### 3.2 옵셔널 체이닝(`.?`)

```javascript
const adventurer = {
 name: 'Alice',
 cat: {
  name: 'Dinah'
 }
};

console.log(adventurer.cat?.name); // Dinah
console.log(adventurer.dog?.name); // undefined
console.log(adventurer.someNonExistentMethod?.()); // undefined
```

[참조: MDN Optional chaining](https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Operators/Optional_chaining)

---

## 4. 객체

- 프로토타입(`__proto__`) 활용을 추천하지 않는다.

### 4.1 프로퍼티

- 프로퍼티 축약 표현을 추천한다.
- 계산된 프로퍼티 이름 활용 방식이 있다.

#### 4.1.1 프로퍼티 축약 표현

- 프로퍼티명과 프로퍼티에 할당하는 변수명이 같을 경우 그대로 쓴다.

```javascript
const name= 'john';

const member = {
 idx: 1,
 name, // 프로퍼티 명과 프로퍼티에 할당하는 값의 변수명이 같다.
};

console.log(member); // {idx: 1, name: 'john'}
```

##### 4.4.1.2 계산된 프로퍼티 이름

```javascript
const prefix = 'prop';
let i = 0;

const obj = {
 [`${prefix}-${++i}`]:i,
 [`${prefix}-${++i}`]:i,
 [`${prefix}-${++i}`]:i,
};

console.log(obj); // {prop-1: 1, prop-2: 2, prop-3: 3}
```

#### 4.4.2 메서드

- 적절한 상황에 메서드 축약 표현을 사용한다.

##### 4.4.2.1 메서드 축약 표현

- ES6 이후에서의 메서드란, 축약 표현으로 정의된 함수만을 의미한다.
- 메서드는 생성자 함수로써 쓰일 수 없다.
- 메서드는 프로토타입이 없다.
- 메서드는 `super`를 사용 가능하다. (프로토타입)

```javascript
const obj = {
 name: 'Lee',
 sayHi() {
  console.log("Hi I'm" + this.name);
 }
};
```

---

## 5. 함수

- JavaScript 함수는 다음과 같다.
  - 일반 function
    - 익명 함수
  - 화살표 함수
  - 생성자
  - 메서드

### 5.1 this

- this는 함수 선언 방식에 따라, 위치가 다르므로, 사용을 최소화할 것을 추천한다.

#### 5.1.1 일반 function

- this는 function을 선언한 위치가 된다.
- call by sharing 이므로 this는 공유된다.
- 객체로서 객체 내부의 값을 연산할 필요성이 있을때 추천한다.

```javascript
const name = 'bar';

const foo = {
 name: 'foo',
 getName: function() {
  console.log(this.name);
 },
};

foo.getName(); //foo
```

#### 5.1.2 화살표 함수

- this는 화살표 함수를 호출한 위치가 된다.
- 모듈의 기능 제공에 추천한다.

```javascript
const name = 'bar';

const foo = {
 name: 'foo',
 getName: () => {
  console.log(this.name);
 },
};

foo.getName(); // bar
```

#### 5.1.3 생성자 함수(new)에 의한 인스턴스의 function

- this는 생성된 인스턴스를 의미한다.
- 객체 생성 방식을 추천하지 않는다.
  - 하나의 로직 안에서 동일한 구조의 객체를 여러번 생성할 때, 추천한다.
  - 생성자 함수로 사용시, return을 지양한다.

```javascript
const Circle = function(radius) {
 this.radius = radius;
 this.getDiameter = function() {
  return 2 * this.radius;
 };
};
const circle1 = new Circle(5);
const circle2 = new Circle(10);

// this는 각각의 인스턴스를 가리킨다.
console.log(circle1.getDiameter()); //10
console.log(circle2.getDiameter()); //20
```

### 5.2 함수 호이스팅 방지

- const 로 변수 선언과 할당을 함으로써, 함수의 호이스팅을 방지한다.

```javascript
/* 함수 선언시 호이스팅이 적용되므로, const로 할당함으로써, 혼동을 방지한다.
 (컴파일러의 '=' 기준 우측 표현식 우선 파싱 특징을 이용한, 호이스팅 방지) */
const foo = function() {
 // ~
};
const bar = () => {
 // ~
};
```

### 5.3 책임 분리

- 책임에 따라 적확하게 작명한다.
- 콜스택이 쌓이더라도, 하나의 함수는 하나의 동작만 하는 것을 추천한다.
- '데이터 호출' / '비즈니스' / '프레젠테이션'으로 로직을 분리할 것을 추천한다.
- parameter/return을 명확히하고 독립적으로 작성함으로써, 사이드이펙트를 줄이는 방향을 지향한다.

#### 5.3.1 데이터 호출 함수

- API로 부터 데이터 호출
- 사이드이펙트를 지양한다.
  - input과 output을 명확히 하고, 외부와 독립한다.

#### 5.3.2 비즈니스 로직 함수

- 유효성 연산
- 기타 연산
- 사이드이펙트를 지양한다.
  - input과 output을 명확히 하고, 외부와 독립한다.

#### 5.3.3 프레젠테이션 로직 함수

- DOM 객체 어트리뷰트 / 프로퍼티에 영향
- event 처리

### 5.4 매개변수

#### 5.4.1 default 매개변수

- 작성을 추천한다.
- 타입과 기본값 명시 용도

```javascript
const foo = function(bar = 1) {
 console.log(bar);
};
foo(); // 1
```

#### 5.4.2 구조분해 할당

- 인자를 facade하게 하는 것을 추천한다.
  - 매개변수 갯수는 3개 초과 되지 않는 것을 추천한다.

```javascript
const foo = function({name, age, depart}, kind = '참가자') {
 console.log(kind + '는 ' + age +'살 '+ name + '이며, '+ depart + '입니다.');
};

const bar = {
 name: '철수',
 age: 19,
 depart: '1반',
};
foo(bar, '도전자'); // 도전자는 19살 철수이며, 1반입니다.
```

#### 5.4.3 나머지 매개변수 (`...`)

- 나머지 매개변수 활용을 추천한다.

```javascript
const foo = function(...members) { // 나머지 매개변수
 const outputString = members.reduce((acc, cur, idx)=> acc + idx + '.' + cur + ' ', '');
 console.log(outputString); // 0.철수 1.영희 2.짱구 3.훈이 
};

const members = ['철수', '영희', '짱구', '훈이'];
foo(...members); // 전개 연산자
```

---

## 6. 비동기

- 콜백 방식 부정적
  - 콜백 지옥 우려
- 비동기를 위한, 프로미스 처리 기능 추천 (다음 중 택 1)
  1. 프로미스 처리 함수 then
  2. async await
- 쿼리 요청(트래픽)을 줄이고자, 쓰로틀링과 디바운스 처리를 지향한다.

### 6.1 프로미스 처리: 체이닝 함수 `then`

- 세부적인 프로미스 처리가 가능하다.
- async await 방식을 좀 더 추천
  - then을 통해 코드의 들여쓰기가 많아지면, 가독성이 저해된다.
  - catch 구문이 많아지면, 가독성이 저해된다.

```javascript
const axios = require('axios');

const Test1ApiCall = () {
 axios
  .get('/user?ID=12345')
  // 응답(성공)
  .then(function(response) {
   console.log("Response >>", response.data);
  })
  // 응답(실패)
  .catch(function(error) {
   console.log("Error >>", error);
  })
  // 응답(항상 실행)
  .then(function() {
   // ...
  });
};

// then 을 연속적으로 호출하는 예시
// 복잡하다.. => async await 추천
const Test2ApiCall = () {
 // axios 요청1
 axios
  .get('https://test.com/api/v1')
  .then((response) => {
   const data = response.data;
   const userId = data.userId;
   // axios 요청2
   axios
    .get('https://test2.com/api/v2/' + userId)
    .then((response) => {
     console.log("Response >>", response.data);
    })
    .catch(() => {
     console.log("Error >>", err);
    })
  })
  .catch((error) => {
   console.log("Error >>", err);
  });
};
```

### 6.2 async await

- try catch와 같이 사용이 용이하다.

```javascript
// async/await 를 활용하는 수정된 방식
const Test2ApiCall = async () {
 console.log(2);
 try {
  // axios 요청1
  const response = await axios.get('https://test.com/api/v1');
  console.log(7);
  const userId = response.data.userId;
  // axios 요청2
  const response2 = await axios.get('https://test2.com/api/v2/' + userId);
  console.log(8);
  console.log("Response >>", response2.data);
 } catch(err) {
  console.log("Error >>", err);
 } finally {
  console.log('끝');
 }
}

console.log(1);
Test2ApiCall();
console.log(3);
console.log(4);
console.log(5);
console.log(6);
// 출력 순서
// 1
// 2
// 3
// 4
// 5
// 6
// 7
// 8
// Response >> ~ or Error >> ~ 
```

- 비동기 처리시, await을 만나는 순간, async 함수 바깥의 콜스택을 처리한다는 점을 주의

### 6.3 중첩된 비동기 처리

```javascript
// 잘못된 예
import fs from 'fs-promise';

async function printFiles() {
 const files = await getFilePaths(); // Assume this works fine

 files.forEach(async (file) => {
  const contents = await fs.readFile(file, 'utf8');
  console.log(contents);
 });
}

printFiles();
// 작동하지만, printFiles가 비동기를 한번에 실행, 기다리지 않고 바로 리턴
```

- 바벨은 async/await를 generator 함수로 변환하는데, forEach를 쓰면 각각의 이터레이션이 개별 generator 함수를 갖게 된다.
  - next( ) 컨텍스트가 아니다.

#### 6.3.1 `for ... of ...` 순서대로 비동기 처리

```javascript
async function printFiles() {
 const files = await getFilePaths();

 for (let file of files) {
  const contents = await fs.readFile(file, 'utf8');
  console.log(contents);
 }
}
```

#### 6.3.2 `reduce` 함수

- 순서를 보장하는 reduce를 사용
  - map, filter는 순서를 보장하지 않는다.

```javascript
async function printFiles() {
 const files = await getFilePaths();

 await files.reduce(async (promise, file) => {
  await promise; // 이전 프로미스들의 resolve를 기다린다.
  const contents = await fs.readFile(file, 'utf8');
  console.log(contents);
 }, Promise.resolve());
}
```

#### 6.3.3 `Promise.all( )` 비동기 처리

- map은 새 배열을 반환하기 때문에,
  - 매개변수로 배열을 받는 Promise.all 안에 배열을 매핑한다.
  - 같은 이유로 forEach는 안된다. 리턴값을 기다리지 않기 때문이다.

```javascript
async function printFiles() {
 const files = await getFilePaths();

 await Promise.all(files.map(async (file) => {
  const contents = await fs.readFile(file, 'utf8');
  console.log(contents);
 }));
}
```

- 참조
- [stackoverflow: Using async/await with a forEach loop](stackoverflow.com/questions/37576685/using-async-await-with-a-foreach-loop)
- [Handling Nested Promises Using Async/Await in React](www.pluralsight.com/guides/handling-nested-promises-using-asyncawait-in-react)

### 6.4 쓰로틀링과 디바운스 처리

#### 6.4.1 디바운스(Debouncing)

- 일정 시간동안 대기, 대기 중 함수가 호출된다면, 대기 시간 초기화
  - Ex) 단어 검색 자동 조회

```javascript
let timer;
document.querySelector('#input').addEventListener('input', function(e) {
  if (timer) {
    clearTimeout(timer);
  }
  timer = setTimeout(function() {
   // ~~~내용~~~
  }, 200);
});
```

#### 6.4.2 쓰로틀링(Throttling)

- 마지막 실행후, 일정 시간까지 대기
  - Ex) 스크롤 다운 추가 조회

```javascript
let timer;
document.querySelector('.body').addEventListener('scroll', function(e) {
 if (!timer) {
  timer = setTimeout(function() {
   timer = null;
   // ~~~내용~~~
  }, 200);
 }
});
```
