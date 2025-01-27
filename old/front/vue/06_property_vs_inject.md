# 프로퍼티 props
- html에서 프로퍼티를 줄 수 있다.
- 컴포넌트에서 프로퍼티를 props 리스트로 받을 수 있다.
    - this가 해당 명칭으로 props를 받게 된다.
- 프로퍼티는 immutable 불변하다.
    - **단방향으로 데이터가 이동**된다. 
        - 부모에서 자식으로 내려보내진 프로퍼티 데이터는 자식은 변경불가, **부모만 변경 가능**하다.

- App.vue
```js
<friend-contact
    name="Manuel Lorenz"
    phone-number="01234 78992"
    v-bind:is-favorite="true"
    v-on:toggle-favorite="togglueFavoriteStatus"
></friend-contact>
<friend-contact
    name="Julie Hones"
    phone-number="0987 65431"
    :is-favorite="false"
    @toggle-favorite="togglueFavoriteStatus"
></friend-contact>

<friend-contact
    v-for="freind in friends"
    :key="friend.id"
    :id="friend.id"
    :name="friend.name"
    :phone-number="friend.phoneNumber"
    :is-favorite="friend.isFavorite"
    @toggle-favorite="togglueFavoriteStatus"
></friend-contact>


methods: {
    togglueFavoriteStatus(friendId){
        const identifiedFriend = this.friends.find(friend => friend.id === friendId);
        identifiedFriend.isFavorite = !identifiedFriend.isFavorite;
    }
}
```

- FriendContact.vue
```js
<template>
    <div>
        <p>{{name}}</p>
        <p>{{phone}}</p>
    </div>
</template>
<script>
export default{
    // props: [ 'name', 'phoneNumber', ],  // vue는 케밥케이스는 허용하지 않는 syntax이므로, 적절하게 카멜케이스로 변경해준다. html에서는 케밥케이스를 써야 한다.
    props: {
        id: {
            type: String,
        },
        name: {
            type: String,
            required: true
        },
        phoneNumber: String,
        emailAddress: {
            type: String,
            required: false,
            default: '@'
            validator: function(value){
                return value.contains('@');
            }
        }
    },
    // emits: ['toggle-favorite'],
    emits: {
        'toggle-favorite': function(id){  // 매개변수: 내보낼 데이터, 한번 작업해주는 함수
            if(id){
                return true;
            }else{
                console.warn('Id is missing!');
                return false;
            }
        }
    },
    data(){
        return {
            phone: '',
        }
    },
    methods:{
        toggleDetails(){
            this.phone = this.phoneNumber; // props는 this가 받는다. 템플릿에서도 사용 가능하다.
        },
        toggleFavorite(){
            this.$emit('toggle-favorite', this.id);// 추가 인자는 전달할 인자
        }

    }
}
</script>
```
<https://v3.vuejs.org/guide/component-props.html>

## 값 타입(type  프로퍼티)
- 문자열(String)
- 숫자(Number)
- 불리언(Boolean)
- 배열(Array)
- 객체(Object)
- 날짜(Date)
- 함수(Function)

### v-디렉터 
- v-for
- v-bind 다 가능


# 자식 => 부모: 이벤트 방출

- `this.$emit('커스텀이벤트')`
- 부모 컴포넌트에서 수신할 수 있는 커스텀 이벤트를 발생
    - 이벤트명은 케밥케이스(값 전달)


- `emits`: 컴포넌트가 어떠한 시점에 발생시킬 커스텀 이벤트를 정의


# 조상 ===> 자식
- provide, inject
    - 특정 컴포넌트에서 이하 모든 자식 컴포넌트들과 어떤 데이터 값을 공유하고자 할 때

```js
data(){
    return topics;
},
methods: {
    activateTopic(topicId){

    }
}

// 조상에서..
provide: {
    topics: this.topics, // data와 코드가 중복
    selectTopic: this.activateTopic
}

//or 메서드 방식으로 변경하여, 같은 메모리 위치의 객체를 사용하도록 한다
provide(){
    return {
        topics: this.topics, // data를 사용
    };
}

// 자식에서..
inject: ['topics', 'selectTopic'],  // 포인터로 가져온다
```
