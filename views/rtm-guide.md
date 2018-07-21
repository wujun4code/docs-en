# Real-time Message Guide

LeanCloud Real-time Messaging service allows you to make a full-featured real-time chat application without having to self-host a backend service. All of your messages are safely stored in the cloud. Offline messages will be delivered through Push Service([APNs](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html) or [FCM](https://firebase.google.com/docs/cloud-messaging/)).

The content of a message is fully customizable.

For example, the code to send a text message is as follows:

```js
conversation.send(new AV.TextMessage('hey guys!'));
```

## Getting Started

### Compatibility

LeanCloud real-time SDK for JavaScript can run on the following platforms(or browsers):

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

the following code show how to create a conversation and send a text message:

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

### Events when receiving messages

```js
// code for Jerry
realtime.createIMClient('Jerry').then(function(jerry) {
  jerry.on(Event.MESSAGE, function(message, conversation) {
    console.log('[jerry] received a message from [' + message.from + ']: ' + message.text);
  });
}).catch(console.error);
```

Here is a preview table for Events:

action\member|tom|jerry|mary
--|--|--|--
`tom.createConversation({members: ['Jerry']})`|Event.MEMBERS_JOINED|Event.INVITED|Event.MEMBERS_JOINED
`tom->conversation.add(['Mary'])`|Event.MEMBERS_JOINED|Event.MEMBERS_JOINED|Event.INVITED
`tom->conversation.remove(['Mary'])`|Event.MEMBERS_LEFT|Event.MEMBERS_LEFT|Event.KICKED
`tom->conversation.quit()`|Event.MEMBERS_LEFT|Event.MEMBERS_LEFT|Event.MEMBERS_LEFT
`tom->conversation.join()`|Event.MEMBERS_JOINED|Event.MEMBERS_JOINED|Event.MEMBERS_JOINED


### Events when members updated

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

At the same time, those notices will be served on Conversation:

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

## Messages

### Creating built-in typed message

Built-in typed message can be found in `leancloud-realtime-plugin-typed-messages` module, the following code show how to send a file message:

case 1. send a file message from local path:

```js
/* html: <input type="file" id="photoFileUpload"> */
var AV = require('leancloud-storage');
var { ImageMessage } = require('leancloud-realtime-plugin-typed-messages');

var fileUploadControl = $('#photoFileUpload')[0];
var file = new AV.File('avatar.jpg', fileUploadControl.files[0]);
file.save().then(function() {
  var message = new ImageMessage(file);
  message.setText('from My iPhone');
  message.setAttributes({ location: 'San Francisco' });
  return conversation.send(message);
}).then(function() {
  console.log('sent');
}).catch(console.error.bind(console));
```

case 2. send a file message from hyper link:

```js
var AV = require('leancloud-storage');
var { ImageMessage } = require('leancloud-realtime-plugin-typed-messages');
// create a new file message with a web link.
var file = new AV.File.withURL('Kuniko Ishigami', 'http://pic2.zhimg.com/6c10e6053c739ed0ce676a0aff15cf1c.gif');
file.save().then(function() {
  var message = new ImageMessage(file);
  message.setText('Kuniko Ishigami');
  return conversation.send(message);
}).then(function() {
  console.log('发送成功');
}).catch(console.error.bind(console));
```

### Receiving messages

```js
// import TypedMessagesPlugin when initialized.
// var realtime = new Realtime({
//   appId: appId,
//   plugins: [TypedMessagesPlugin]
// });
var { Event, TextMessage } = require('leancloud-realtime');
var { FileMessage, ImageMessage, AudioMessage, VideoMessage, LocationMessage } = require('leancloud-realtime-plugin-typed-messages');
// register message handler
client.on(Event.MESSAGE, function messageEventHandler(message, conversation) {
  //put you code here
  var file;
  switch (message.type) {
    case TextMessage.TYPE:
      console.log('收到文本消息， text: ' + message.getText() + ', msgId: ' + message.id);
      break;
    case FileMessage.TYPE:
      file = message.getFile(); // file 是 AV.File 实例
      console.log('收到文件消息，url: ' + file.url() + ', size: ' + file.metaData('size'));
      break;
    case ImageMessage.TYPE:
      file = message.getFile();
      console.log('收到图片消息，url: ' + file.url() + ', width: ' + file.metaData('width'));
      break;
    case AudioMessage.TYPE:
      file = message.getFile();
      console.log('收到音频消息，url: ' + file.url() + ', width: ' + file.metaData('duration'));
      break;
    case VideoMessage.TYPE:
      file = message.getFile();
      console.log('收到视频消息，url: ' + file.url() + ', width: ' + file.metaData('duration'));
      break;
    case LocationMessage.TYPE:
      var location = message.getLocation();
      console.log('收到位置消息，latitude: ' + location.latitude + ', longitude: ' + location.longitude);
      break;
    default:
      console.warn('收到未知类型消息');
  }
});
```


## Messages Sending Options

### Mentioned Member(s)

```js
const message = new TextMessage(`@Jerry`).setMentionList('Jerry').mentionAll();
```

The above code means Jerry was mentioned in this message, here can do something special, for example, Jerry can receive a Push Notification.

Receivers online can get mentioned member list:


```js
client.on(Event.MESSAGE, function messageEventHandler(message, conversation) {
  // here is the mention list,an array like ['Jerry']
  var mentionList = receivedMessage.getMentionList();
});
```

### Push Notifications Customization

Try to set `pushData` when sending message like the following code:

```js
var { Realtime, TextMessage } = require('leancloud-realtime');
var realtime = new Realtime({ appId: 'your app-id here', region: 'us' });
realtime.createIMClient('Tom').then(function (host) {
    return host.createConversation({
        members: ['Jerry'],
        name: 'Tom & Jerry',
        unique: true
    });
}).then(function (conversation) {
    console.log(conversation.id);
    return conversation.send(new TextMessage('Hi Jerry, there is a party tonight, if you wanna join, please let me know before 7:00 pm.'), {
        pushData: {
            "alert": "You have a new message.",// alert text
            "category": "Message",
            "badge": 1,
            "sound": "default.aac",//  alert sound file name.
            "foo": "bar"// put some key-value here
        }
    });
}).then(function (message) {
    console.log(message);
}).catch(console.error);
```

## Conversation Type Division





