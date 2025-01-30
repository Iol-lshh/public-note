# ref
- DOM 요소에 액세스할 때, 순수 JS에서도 사용가능한 JS 객체가 된다.
  - 그 본질적인 특징을 이용해 [Composition API](./10_composition_api.md/#ref)에서도 사용된다.

```js
const app = Vue.createApp({
  data() {
    return {
      currentUserInput: '',
      message: 'Vue is great!',
    };
  },
  methods: {
    saveInput(event) {
      this.currentUserInput = event.target.value;
    },
    setText() {
      // this.message = this.currentUserInput;
      this.message = this.$refs.userText.value;
      console.dir(this.$refs.userText); // input 요소를 가리킴
    },
  },
});

app.mount('#app');
```
```html
  <body>
    <header>
      <h1>Vue Behind The Scenes</h1>
    </header>
    <section id="app">
      <h2>How Vue Works</h2>
      <input type="text" ref="userText">
      <button @click="setText">Set Text</button>
      <p>{{ message }}</p>
    </section>
  </body>
```