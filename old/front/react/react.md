# import
- import는 es6+의 기능이다.

### import할 파일: SomeComponent.js
```js
const SomeComponent = () => {

}
const a = 1;
const b = [];

export default SomeComponent;
export a;
export b;
```
- default는 하나만 가능
    - 표현식을 넘긴다.
- 단순 export는 여러개 가능 
    - export하는 Variable들을 Object에 담아 넘기므로, 반드시 변수명이 필요하다.

### import 하는 파일
```js
// default
import SomeComponent from './SomeComponent'

// not default => 분해 할당 이용
import {a, b} from './SomeComponet'
import SomeComponent, {a, b} from './SomeComponet'
```
- default는 표현식을 받으므로, 명칭이 일치하지 않아도 된다.
- 단순 export는, 분해 할당을 이용하므로, 반드시 변수명이 일치해야한다.
- **import는 소스를 받아오는 행위이다.**
    - 범위는 해당 소스파일로 제한된다.

# JSX
- JSX는 리엑트의 **xml 형태를 띈 표현식**이다.
    - JavaScriptXml

# 컴포넌트
- 리엑트는 컴포넌트라는 함수를 호출하는 것으로 JSX를 반환한다.
    - 호출된 컴포넌트는, 컨택스트 안의 모든 컴포넌트들을 평가한다. (콜스택)

# state
- 이벤트에 의해, 컴포넌트의 내부 변수들이 바뀌어도, 돔의 상태는 바뀌지 않는다.
    - 컴포넌트는 호출 되었을 때, **JSX를 반환해줄 뿐**이고, 반환 받은 JSX들이 돔의 상태를 바꾼다.
    - 때문에 DOM의 상태를 바꾸기 위해서는, **컴포넌트를 재호출하여 변경된 JSX를 받아, 기존 DOM을 바꿔야 한다.**
- 상태값이 변경되었을 때, 컴포넌트 함수를 자동으로 호출하기 위해, React는 useState라는 컴포넌트의 내장 함수를 지원한다.
```js
import { useState } from 'react'

const SomeComponent = (props) => {
    const defaultValue = props.someValue;
    const [getterValue, setterFunction] = useState(defaultValue);
    
    const someEventHandler = (someEventValue) => {
        setterFunction(someEventValue);
    }
}
```
- useState
    - React 라이브러리로부터 가져온다.
    - 컴포넌트의 내장 함수
    - getter와 setter를 리스트에 담아 반환한다.
    - getter는 현재 값 value
    - setter는 상태 업데이트용 함수 Function 
- setterFunction
    - setState 의 형태로 이름을 짓는다.
    - setter가 동작시, 컴포넌트 함수가 재호출 된다. 
        - **마이크로 태스크 큐에 담겨, 모든 실행 컨텍스트 콜스택이 비워지면 실행된다.**
        - 즉, 함수 호출 되자마자, 해당 실행 컨텍스트에서 상태가 바뀌는 것은 아니라는 뜻!

- getterValue
    - state 의 형태로 이름을 짓는다.
- defaultValue
    - 상태값이 setterFuction에 의하여 변하기 전, 최초 렌더링에 초기화할 값이다.

## State를 부모 컴포넌트를 올리기
```js

const DUMMY = [];
const [expenses, setExpenses] = useState(DUMMY);
const onAddExpense = (expense) => {
    setExpenses((prevExpenses)=>{
        return [expenses, ...prevExpenses];
    });
};

return (
    <div>
        <NewExpense onAddExpense = {addExpenseHandler}>
        <Expenses items={expenses}>
    </div>
);
```
- 함수를 전달한다. (포인트, 훅)







