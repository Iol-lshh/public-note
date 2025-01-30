# 로컬 컴포넌트 import
```html

<script>
import TheHeader from './components/TheHeader.vue'

export default {
    components: {
        // 'the-header': TheHeader
        // TheHeader: TheHeader
        TheHeader
    }
}
</script>
```
- main js에서 불러오면, 전역 반영되나,
- 로컬에서 import시, 지역 반영된다.

## scoped
- 지역의 template에만 반영

```html
<style scoped>
</style>
```

## Slots

- 부모
```html
<template>
    <section>
        <base-card>
            <!-- <template v-slot:header> -->
            <template #header>
                <h3>{{fullName}}</h3>
            </template>
            <!-- <template>
                <p>{{infoText}}</p>
            </template> -->
            <template v-slot:default>
                <p>{{infoText}}</p>
            </template>
        </base-card>
    </section>
</template>
```

- 자식(base-card)
```html
<template>
    <div>
        <!-- <header v-if="$slots.header"> -->
        <header v-if="$slots.header">
            <slot name="header">
                <h2>The Default</h2>
            </slot>
        </header>
        <slot></slot>
    </div>
</template>
```
- vue 기능을 사용할 수도 있는 **HTML 컨텐츠(template)**를 외부 컴포넌트로부터 수신할 수 있게 해준다.
    - cf) props 는 데이터
- name 으로 이름을 붙일 수 있다.
    - 이름이 없는 슬롯은 default 슬롯이다.
        - name이 없는 슬롯은 하나만 있을 수 있다.
- `v-slot`: vue에 특정 컨텐츠가 어디로 가야 할지를 알려준다.
    - `#`로 축약할 수 있다. 

- slot이 없을 경우, 본래 태그 내부 요소들이 default로써 렌더링된다.
- `$slots`:  vue에서 제공하는 내장 프로퍼티. 컴포넌트가 다른 슬롯에 의해 수신하는 수신 데이터 정보 보유

# 동적 컴포넌트 
```html
<component :is="selectedComponent"></component>
```
- is 프로퍼티에, 정의한 컴포넌트의 이름을 넣음으로써, component 태그에 보여줄 수 있다.
    - 동적 컴포넌트 교체에 유리하다.
        - v-if를 일일히 할 필요가 없다.
## keep-alive
- 동적 컴포넌트를 감싼다.
    - 컴포넌트를 완전히 제거하지 않고, 내부에서 상태를 캐싱하도록 한다.(가상 돔)
```html
<keep-alive>
    <component :is="selectedComponent"></component>
</keep-alive>
```


# dialog 컴포넌트
- 기본 html 요소

- ErrorAlert.vue
```html
<template>
    <dialog open>
        <slot></slot>
    </dialog>
</template>

<style scoped>
    dialog {
        margin: 0;
        position: fixed;
        top: 20vh;
        left: 30%;
        width: 40%;
        backgroud-color: white;
        box-shadow: 0 2px 8px rgba(0,0,0,0.26);
        padding: 1rem;
    }
</style>
```

- parent
```html
<template>
    <teleport to="body">
        <error-alert v-if="inputIsInvalid">
            <h2>Input is invalid</h2>
        </error-alert>
    </teleport>
</template>
<script>
    import ErrorAlert from './ErrorAlert.vue';
    components: {
        ErrorAlert
    },
    ...
</script>
```

## 텔레포트 Teleport
- 태그 위치를 dom의 원하는 위치로
    - to 프로퍼티: CSS 셀렉터를 넣어, 전체 페이지에서, 해당 내용이 추가되어야 할, HTML 요소를 선택
    - 컴포넌트의 위치(상속 관계)는 동일하나, 실제 HTML에서 위치가 변경된다.

## Fragment
- vue 2에서는 template안의 root는 하나여야만 했으나, vue 3에서는 여러개여도 된다. 
    - 이를 프래그먼트라 한다. (복수의 상위 레벨 요소를 가질 수 있다.)


## 스타일 가이드
- 기본 컴포넌트가 아닌, 단일 인스턴스 컴포넌트는 The를 붙이는 것을 권장한다.
 