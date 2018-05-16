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

Use a globally id to connect to server:

```js
// choose 'Tom' as the globally id
realtime.createIMClient('Tom').then(tom=> {
  // tom is an instance of AVIMClient
});
```

## Conversations

Once connected, clients can send and receive messages, which are tied to a specific Conversation object.

the following codes show how to create a conversation and send a text message:

```js
// choose 'Tom' as the globally id
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

### Fetch a existing Conversation







