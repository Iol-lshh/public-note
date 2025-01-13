> - [vue-router 설치](#vue-router-설치)
>   - [createRouter](#createrouter)
>   - [createWebHistory](#createwebhistory)
> - [사용 예](#사용-예)
>   - [$router](#router)
>   - [:param 동적 경로 세그먼트(인자)](#param-동적-경로-세그먼트인자)
>       - [$route](#route)
>       - [watcher와 연계](#watcher와-연계)
> - [라우팅 옵션](#라우팅-옵션)
>   - [props](#props)
>   - [redirect](#redirect)
>   - [alias](#alias)
>   - [notFound](#notfound)
>   - [children 라우팅](#children-라우팅)
>   - [객체 방식의 라우팅](#객체-방식의-라우팅)
> - [라우터 추가 기능](#라우터-추가-기능)
>   - [scrollBehavior 스크롤 기억](#scrollbehaviorto-from-savedposition)
> - [네비게이션 가드](#네비게이션-가드)
>   - [beforeEach](#beforeeach)
>   - [beforeEnter](#beforeenter)
>   - [beforeRouteEnter](#beforerouteenter)
>   - [afterEach](#aftereach)
>   - [beforeRouteLeave](#beforerouteleave)
> - [라우트 메타필드](#라우트-메타필드)

# vue-router 설치
- `npm install --save vue-router`

## createRouter
- 라우팅 기능

## createWebHistory
- 브라우저 내장 기능
- 히스토리 기능 (뒤로가기 등)

# 사용 예
- main.js
```js
import { createApp } from 'vue';
import './style.css';
import { createRouter, createWebHistory } from 'vue-router';
import App from './App.vue';
import TeamsList from './components/teams/TeamsList.vue';
import UsersList from './components/users/UsersList.vue';

const router = createRouter({
    history: createWebHistory(), 
    routes: [
        { path: '/teams', component: TeamsList },
        { path: '/users', component: UsersList },
    ],
});

const app = createApp(App);
app.use(router);    // 서드파티를 연결
app.mount('#app');
```

- App.vue
```js
<template>
    <the-navigation @set-page="setActivePage"></the-navigation>
    <main>
        <router-view></router-view>
    </main>
    <footer>
        <router-view name="footer"></router-view>
    </footer>
</template>
```

- `<router-view>`
    - 해당 위치로 컴포넌트가 로드되어야 함을, vue 앱에게 알리는 플레이스 홀더의 역할
```js
<nav>
    <ul>
        <li>
            <router-link to="/teams">Teams</router-link>
        </li>
        <li>
            <router-link to="/users">Users</router-link>
        </li>
    </ul>
</nav>
```
- `<router-link>`
    - 특별한 앵커 태그 - 브라우저 기본값으로 로드되는걸 막고, vue 라우터를 이용하여, 알맞은 컴포넌트를 로드하고, url을 변경해준다.
    - to 프로퍼티 중요!

## $router
- `$router.push('/teams')`
    - 해당 라우팅으로 옮긴다.

## :param 동적 경로 세그먼트(인자)
```js
...
import TeamMembers from './components/teams/TeamMember.vue';

const router = createRouter({
    history: createWebHistory(), 
    routes: [
        { path: '/teams', component: TeamsList },
        { path: '/users', component: UsersList },
        { path: '/teams/:teamId', component: TeamMembers },
    ],
});
```
### $route
- `$route`로 받을 수 있다.
```js
const teamId = this.$route.params.teamId
```

### watcher와 연계
- watcher를 이용하여, $route를 감시하면, 뷰가 동작을 감지할 수 있다.
```
watch: {
    $route(newRoute){
        ...
    }
}
```
- 라우터는 create 시에만 동작하기 때문에.
    - 뷰가 라우터의 특정 동적 동작을 감지 못한다.
    - 때문에 와쳐를 붙여서 동작을 감지하도록 한다.


# 라우팅 옵션

## props
```js
{path, component, props: true}
```
- vue 라우터에 동적 매개변수가 $route 프로퍼티에만 전달되는 게 아니라, 프로퍼티로서 컴포넌트에 전달되도록 한다.
    - 동적매개변수. 경로에 달린 동적 경로 세그먼트

## redirect
```js
{path: '/', redirect: '/teams'}
```
- path 를 리다이렉션 한다.
- url이 바뀐다.

## alias
```js
{path: '/teams', component: TeamsList, alias: '/'}
```
- alias도 라우팅한다.
- url이 바뀌지 않는다.

## notFound
- 경로를 찾지 못했을 때를 처리하는 방식이다.
- 정규식으로 매핑하므로,
    - 다른 매핑되어야 할 라우팅 뒤에 두어야 한다.
```js
{path: '/:notFound(.*)', redirect: 'teams'}

//or
{path: '/:notFound(.*)', component: 'NotFound'}
```

## children 라우팅
- 자식 라우터로 둠으로써, `/teams/:teaId` 에 놓여진다.
    - 다만, `/teams` 내부에서만, 라우팅이 가능하다.
```js
{
    path: '/teams',
    component: TeamsList,
    children: [
        {path: '/:teamId', component: TeamMembers, props: true}
    ]
}
```
- TeamsList.vue
```js
<template>
    <router-view></router-view>
</template>
```


## 객체 방식의 라우팅
- 객체에 정보를 담는 형식으로 라우터를 구성가능하다.
```html
<template>
  <li>
    <h3>{{ name }}</h3>
    <div class="team-members">{{ memberCount }} Members</div>
    <router-link :to="teamMembersLink">View Members</router-link>
  </li>
</template>

<script>
export default {
  props: ['id', 'name', 'memberCount'],
  computed: {
    teamMembersLink() {
      // return '/teams/' + this.id + '?sort=asc';
      return {
        name: 'team-members',
        params: { teamId: this.id },
        query: { sort: 'asc' },
      };
      // this.$router.push({ name: 'team-members', params: { teamId: this.id } });
    },
  },
};
</script>
```

# 라우터 추가 기능
## scrollBehavior(to, from, savedPosition)
- 라우팅의 전후에 대한, 페이지 스크롤 위치를 기억해주는 기능
    - `to`: this.$route에서 얻을 수 있는 라우트 객체. 이동했던 페이지
    - `from`: this.$route에서 얻을 수 있는 라우트 객체. 이전 페이지
    - `savedPosition`: 뒤로가기 버튼시에만 사용. 
        - 이전 페이지에서 사용자 스크롤 위치를 `left`, `top` (css)으로 기억한다.

```js
// ex1) 페이지 이동시, 맨 위로 올릴 수 있다.
scrollBehavior(to, from, savedPosition){
    return { left: 0, top: 0 };
}
```

```js
// ex2)  뒤로가기시에는, 이전 위치를 기억해준다.
scrollBehavior(to, from, savedPosition){
    if(savedPosition){
        return savedPosition;
    }
    return { left: 0, top: 0 };
}
```

# 네비게이션 가드
- 라우터에 의한 페이지 이동을 감지하고, 기능 확장을 지원하는 기능
    - **인증 인가 구현**, **양식 저장 알림** 등에 유용하다.
- 사용자가 양식을 저장하지 않고 실수로 나가는 것을 방지해주기도 한다
    - `to`: 이동할 페이지의 라우트 객체
    - `from`: 이전 페이지의 라우트 객체
    - `next`: 네비게이션 동작을 승인하거나 취소할때, 호출하는 함수
- 네비게이션 가드는 범위에 따라 세가지이며, 다음 **실행 순서**는 다음과 같다. (전역 > 지역) 
    1. 컴포넌트를 떠날때 (비활성화 될 컴포넌트의 [beforeRouteLeave](#beforerouteleave))
    2. 전역 네비게시션 가드(global [beforeEach](#beforeeach))
    3. 재사용 컴포넌트시 (컴포넌트의 [beforeRouteUpdate](#beforerouteupdate))
    4. 라우트 구성 수준 네비게이션 가드(라우트의 [beforeEnter](#beforeenter))
    5. 컴포넌트 수준(컴포넌트의 [beforeRouteEnter](#beforerouteenter))
    6. 라우팅 완료 (global [beforeResolve](#beforeresolve)
    7. 컴포넌트 떠나는 것이 승인되었을 때 (global [afterEach](#aftereach)) 
    8. beforeMount > mount > DOM 갱신
    9. micro task queue 에서 beforeRouteEnter의 콜백 호출

## beforeEach
- 라우터 객체 외부에서 메서드로 준다.
    - 전역의 라우트 승인 확인 구현이 가능하다.
        - 승인하거나, 거부하고 리다이렉션
- main.js
```js
router.beforeEach(function(to, from, next){
    next();
    // next(false); // 이동 취소
    // next('등록된 라우트'); // 등록된 라우트로 고정 이동
})
```
- 인증 등의 사용에 유리

## beforeEnter
- router 객체 속성으로써, 전역에서 호출
    - 전역의 라우트 승인 확인 구현이 가능하다.
- router 구성의 객체에 메서드로 준다 (컴포넌트 지역)
```js
beforeEnter(to, from, next){
    next();
}
```

## beforeRouteEnter
- 이동하려는 컴포넌트에서 호출
    - 이 컴포넌트에서 승인 확인 구현이 가능하다.
- 컴포넌트에 메서드로 준다 (컴포넌트 내부)
```js
beforeRouteEnter(to, from, next){
    next();
}
```
- 사용자의 특정 페이지로의 이동에 대한 인가를 구현할 수 있다.



## afterEach
- 라우팅 여부가 결정된 후, 라우팅 되기 직전 호출
- 라우터 자체에 메서드로 준다. (전역)
- main.js
```js
router.afterEach(function(to, from){
    next();
})
```
- 실행되면, 이미 이동이 승인된 이후이기 때문에, next 함수는 없다.
- 이동 거부를 할 수 없다.
- 분석 데이터를 보내는데 유리하다.
    - 이동 액션, 로그 등

## beforeRouteLeave
- 컴포넌트에 메서드로 준다 (컴포넌트 내부)
- 떠나기 직전, 페이지 떠나는 액션을 거부할 때 (이동을 취소할 때)
    - 사용자가 페이지를 저장하지 않고 떠날때, 알럿을 띄운다던지 할 때
    - 이후, beforeEach, beforeEnter 등의 네비게이터를 실행한다.
```js
beforeRouteLeave(to, from, next){
    if(this.changesSaved){
        next();
    }else{
        const isWantedToLeave = prompt('are you sure? you got unsaved changes');
        next(isWantedToLeave);
    }
}
```

# 라우트 메타필드
- 라우트 구성에 meta 프로퍼티를 추가할 수 있다.
```js
routes: [
    {
        name: '~',
        path: '/',
        meta: { needsAuth: true },
        components: { default: TeamsList },
        children: [],
    }
]

~~~~

router.beforeEach(function(to, from, next){
    if(!to.meta.needsAuth){
        console.log('Needs Auth');
        next(false);
    }else{
        next();
    }
})
```
- 라우트 객체나 $route 객체가 있는 곳 모두에서 메타 필드에 액세스 가능하다.
    - 라우트에 로드된 컴포넌트에 데이터 전달할 수 있다.
    - 네비게이션 가드의 to, from 객체에서 액세스할 수 있다.


