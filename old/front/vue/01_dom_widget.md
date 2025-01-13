# vue
- vue는 **선언형 접근 방식**을 사용한다
    - 동적 플레이스만 **정의하면**, **중간 단계를 vue가 직접 작업**한다는 것을 의미

# vue dom property
- 보간법 interpolation {{}} 
    - html 태그 안에서만 가능

## vue 내장 디렉티브
### 바인딩
- v-bind
    - 보간법의 html 속성 버전
    - 보간법에서는 js 표현식이 가능하다.
    - `:` 콜론으로 대체 가능
        - `v-bind:name` => `:name`
- v-html
    - XSS 보안을 위해 지양한다.
- v-on
    - 이벤트를 바인드하여 헨들러를 정의한다. js 코드를 넣을 수 있다.
    - 값을 넣어도 되고, 헨들러(함수)를 넣어도 된다.
    - `@` at으로 대체 가능
        - `v-on:click` => `@click`
- v-once
    - 한번만 반영. 태그의 초기값 고정
- v-model
    - 프로퍼티를 **양방향** 바인딩
    - v-on + v-bind:value 와 동일

### vue 지원 변수
- $event
    - vue에서 지원하는 dom의 event 변수
### vue 모디파이어
- .prevent
    - 기본 ssr 방지
- .right
    - 우클릭에 반응
- key
    - 키보드 이벤트에 반응
    - .enter
- .stop

### 동적 스타일링
- style은 특이하다.
```js
// 인라인 스타일링
v-bind:style="{borderColor: boxASelected ? 'red' : '#ccc'}"
// 클래스 바인딩을 이용한 인라인 스타일링
v-bind:class="boxASelected ? 'demo active' : 'demo'"
// 클래스 바인딩을 이용한 인라인 스타일링2 - 클래스 바인딩 특수 기능
class="demo" :class="{active: boxASelected}"
// computed 프로퍼티로 클래스를 넘길 수 있다.
boxAClasses(){
    return {active: this.boxASelected}
}
class="demo" :class="boxAClasses"
// 배열 전달 가능
:class="['demo', {active: boxASelected}]"
```

### 조건부 렌더링
- v-if
- v-for
```js
const goals = [];
// 기본 동작
<li v-for="goal in goals">{{goal}}</li>
// element, index
<li v-for="(goal, index) in goals">No{{index}}: {{goal}}</li>
// 객체에도 사용 가능
<li v-for="(value, key, index) in {name: 'Max', age: 31}">{{index}}. {{key}}: {{value}}</li>

// key - 버그 방지 (성능을 위해, vue가 첫번째 dom만을 비교하기 때문에 키를 통해 비교하게 한다.)
<li v-for="(goal, index) in goals" :key="goal">No{{index}}: {{goal}}</li>
```


# Vue 기본 property
- data
    - 상태
    - 프록시로 감싸져, 반응성을 갖게 된다.
- methods
    - 이벤트와 데이터 바인딩에 쓰인다.
    - 데이터 바인딩의 경우, 의존성이 뷰 전체 프로퍼티에 있어, 매번 반응한다.
- computed
    - 여러 data 프로퍼티에 의존성 반응 (this)
        - 컨텍스트 내부에 쓰인 data 프로퍼티들의 변화를 감지하여 동작
    - 계산된 값에 좋다.
- watch
    - watcher 감시자 (트리거라고 생각해도 좋을 것..?)
    - 명칭과 동일한 data 프로퍼티의 상태에 의존성을 갖고 반응
        - 단일 상태를 감시하고 동작하게 된다.
        - 첫번째 인자는 변화되는 값
        - 두번째 인자는 변화 이전의 값

## 위젯 예시

```html
<head>
    <script src="https://unpkg.com/vue@next" defer></script>
    <script src="app.js" defer></script>
</head>
<body>
    <header>
        <h1>Vue Course Goals</h1>
    </header>
    <section id="user-goal">
        <h2>My Course Goal</h2>
        <p>{{ courseGoal }}</p>
        <p v-once>{{ courseGoal }}</p>
        <!-- <p v-html="outputGoal()"></p> -->
        <p>{{outputGoal()}}</p>
        <p>learn more <a v-bind:href="vueLink">about Vue</a></p>
        
        <button v-on:click="counter++">Add1</button>
        <button v-on:click="add()">Add2</button>
        <button v-on:click="add">Add3</button>
        <button v-on:click="counter--">Remove</button>
        <button v-on:click="subtract(5)">Subtract 5</button>
        <p>Result: {{counter}}</p>
        
        <input type="text" v-on:input="setName">
        <input type="text" v-on:input="setName2($event, 'ha')" v-on:keyup.enter="confirmInput">
        <p>Your Name: {{name}}</p>
        <p>Your confirmed Name: {{confirmName}}</p>

        <form v-on:submit="submitForm">
            <input type="text">
            <button>Sign up</button>
        </form>
         <form v-on:submit2.prevent="submitForm">
            <input type="text">
            <button>Sign up</button>
        </form>

        <input type="text" v-on:input="setName3($event, 'ha')" v-bind:value="name3">
        <input type="text" v-model="name3">
        <button v-on:click="resetInput">Remove</button>
        <p>Your Name: {{name3}}</p>


        <input type="text" v-model="name3">
        <button v-on:click="resetInput">Remove</button>
        <p>Your Name: {{outputFullname()}}</p> <!-- 이상적이지 못하다. => 필요없을때도, 페이지 변경시마다 실행된다. -->
        <p>Your Name: {{fullname}}</p> <!-- computed 프로퍼티는, data 프로퍼티처럼 사용 -->

    </section>
</body>
```
```js
const app = Vue.createApp({
    data(){
        return {
            courseGoal: 'hello world!',
            vueLink: 'https://vuejs.org',
            courseGoal1: 'learn vue',
            courseGoal2: 'master vue',
            courseGoal3: '<h2>vue!</h2>',

            counter: 0,

            name: '',
            confirmName: '',

            name3: '',

            name4: '',
            fullname2: '',
            name5: '',
            name6: '',
        };
    },
    computed: { 
        //computed 프로퍼티는, data 프로퍼티처럼 사용. 의존성을 인지
        fullname(){
            if(this.name ===''){
                return '';
            }
            return this.name + 'ha';
        }
    },
    watch: {
        name4(){
            // data name4에 의존성을 가지게 된다.
            if(this.name ===''){
                this.fullname = '';
            }else{
                this.fullname = this.name + 'ha';
            }
        },
        name5(value){
            this.fullname = value + 'ha';
        },
        name6(newValue, oldValue){
        },
        counter(value){
            // 이런식으로 조건으로 활용에 좋다.
            if(value > 50){
                this.counter = 0;
            }
        }
    },
    methods: {
        outputGoal(){
            const randomNumber = Math.random();
            return randomNumber < 0.5 ?
                this.courseGoal1 : this.courseGoal2;
        },
        add(){
           this.counter++; 
        },
        subtract(num){
            this.counter -= num;
        },
        setName(event){
            this.name = event.target.value;
        },
        setName2(event, lastName){
            this.name = event.target.value + lastName;
        },
        submitForm(event){
            event.preventDefault();
            alert('submitted!');
        },
        submitForm2(event){
            alert('submitted!');
        },
        confirmInput(event){
            this.confirmName = event.target.value;
        },

        setName3(event, lastName){
            this.name = event.target.value + lastName;
        },
        resetInput(){
            this.name2 = ''
        },

        outputFullname(){ // 이상적이지 못하다. => 필요없을때도, 페이지 변경시마다 실행된다.
            if(this.name ===''){
                return '';
            }
            return this.name + 'ha';
        }, 
    },

});

app.mount('#user-goal');
```
- createApp 으로 vue 객체를 만든다.
    - 때문에 객체 내부의 함수에서 this 사용시, vue 객체의 data를 가져오게 된다.




