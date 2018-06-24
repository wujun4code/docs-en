# Real-time Message Guide

Real-time Message on LeanCloud allows you to make a full-featured real-time chat application without having to self-host a backend service. All message history stroed in the cloud safely. Offline messages will be delivered through Push Service(APNS or FCM).
Message content can be flexibly customized.

For example, the code to send a text message is as follows:

```js
conversation.send(new AV.TextMessage('hey guys!'));
```

## Getting Started

### Compatibility

LeanCloud real-time sdk for JavaScript can run on the following platforms(or browsers):

- Browsers/WebView
  - IE 10+ / Edge
  - Chrome 31+
  - Firefox latest
  - iOS 8.0+
  - Android 4.4+
- Node.js 0.12+
- React Native 0.26+

### Install

Install sdk via NPM:

```sh
npm install leancloud-realtime --save
```

### Import

```html
<script src="./node_modules/leancloud-realtime/dist/realtime.browser.js"></script>
```


### Initializing with AppId and AppKey

```js
var realtime = new Realtime({
  appId: 'x7WmVG0x63V6u8MCYM8qxKo8-gzGzoHsz',
  appKey: 'PcDNOjiEpYc0DTz2E9kb5fvu',
  region: 'us', // if in China set region 'cn'
});
```

## Connecting

Use a **unique** id to connect to server:

```js
// choose 'Tom' as the unique id
realtime.createIMClient('Tom').then(tom=> {
  // tom is an instance of AVIMClient
});
```

## Conversations

Once connected, clients can send and receive messages, which are tied to a specific Conversation object.

the following codes show how to create a conversation and send a text message:

```js
// choose 'Tom' as the unique id
realtime.createIMClient('Tom').then(function(tom) {
  // create a conversation containing Tom and Jerry
  return tom.createConversation({
    members: ['Jerry'],// Tom is the creator, so he will automatically join the conversation
    name: 'Tom & Jerry',
  });
}).then(function(conversation) {
  // send a text message
  return conversation.send(new AV.TextMessage('Hi, Jerry.'));
}).then(function(message) {
  console.log('Tom & Jerry', 'message sent.');
}).catch(console.error);
```

> If Jerry has logged in, he will get a notice.For more details please check [Events.MEMBERS_JOINED](#Event.MEMBERS_JOINED)

### Fetch an existing Conversation

Before Tom send message to Jerry, Tom can check if already have a conversation with Jerry.

```js
tom.getQuery().containsMembers(['Jerry']).find().then(function(conversations) {
  // sorted in descend by the timestamp of last message
  conversations.map(function(conversation) {
    console.log(conversation.lastMessageAt.toString(), conversation.members);
  });
}).catch(console.error.bind(console));
```

### Add more participants

One-One Conversation can be transformed to a Group Conversation by inviting more participants.

```js
// fetch an existing Conversation which contains tow members: ['Tom','Jerry']
conversation.add(['Mary']).then(function(conversation) {
  console.log('added', conversation.members);
  // now the conversation contains three members: ['Tom', 'Jerry','Mary']
}).catch(console.error.bind(console));
```
> If Jerry has logged in, he will get a notice.For more details please check [Events.MEMBERS_JOINED](#Event.MEMBERS_JOINED)

> There is nothing logically different between One-One Conversation and Group Conversation. They are both stored in table `_Conversation`, you can check them in console.

### Distinct Conversations

If multiple users independently create Distinct Conversations with the same set of users, the server will automatically manage the conversations.

```js
mary.createConversation({
  members: ['Tom', 'Jerry'],
  name: 'Party on weekends',
  unique: false,// the key code
});
```

### Removing participants

```js
realtime.createIMClient('Tom').then(function(Tom) {
  return Tom.getConversation(CONVERSATION_ID);
}).then(function(conversation) {
  return conversation.remove(['Mary']);
}).then(function(conversation) {
  console.log('Mary has been removed', conversation.members);
}).catch(console.error.bind(console));
```

> If Mary has logged in, he will get a notice.For more details please check [Event.KICKED](#Event.KICKED)

## Events

Here is a preview table for Events:

action\member|tom|jerry|mary
--|--|--|--
`tom.createConversation({members: ['Jerry']})`|Event.MEMBERS_JOINED|Event.INVITED|Event.MEMBERS_JOINED
`tom->conversation.add(['Mary'])`|Event.MEMBERS_JOINED|Event.MEMBERS_JOINED|Event.INVITED
`tom->conversation.remove(['Mary'])`|Event.MEMBERS_LEFT|Event.MEMBERS_LEFT|Event.KICKED
`tom->conversation.quit()`|Event.MEMBERS_LEFT|Event.MEMBERS_LEFT|Event.MEMBERS_LEFT
`tom->conversation.join()`|Event.MEMBERS_JOINED|Event.MEMBERS_JOINED|Event.MEMBERS_JOINED


### Events on members updated

```js
var { Event } = require('leancloud-realtime');

// Tom added Mary
jerry.on(Event.MEMBERS_JOINED, function membersjoinedEventHandler(payload, conversation) {
  console.log(payload.members, payload.invitedBy, conversation.id);
});
// Tom removed Mary
jerry.on(Event.MEMBERS_LEFT, function membersleftEventHandler(payload, conversation) {
  console.log(payload.members, payload.kickedBy, conversation.id);
});
// Jerry joined or Tom added Jerry
jerry.on(Event.INVITED, function invitedEventHandler(payload, conversation) {
  console.log(payload.invitedBy, conversation.id);
});
// Tom removed Jerry:
jerry.on(Event.KICKED, function kickedEventHandler(payload, conversation) {
  console.log(payload.kickedBy, conversation.id);
});
```

At the same time, those notices will be invoked on Conversation:

```js
// Tom added Mary
conversation.on(Event.MEMBERS_JOINED, function membersjoinedEventHandler(payload) {
  console.log(payload.members, payload.invitedBy);
});
// Tom removed Mary
conversation.on(Event.MEMBERS_LEFT, function membersleftEventHandler(payload) {
  console.log(payload.members, payload.kickedBy);
});
// Jerry joined or Tom added Jerry
conversation.on(Event.INVITED, function invitedEventHandler(payload) {
  console.log(payload.invitedBy);
});
// Jerry quitted or Tom removed Jerry
conversation.on(Event.KICKED, function kickedEventHandler(payload) {
  console.log(payload.kickedBy);
});
```
