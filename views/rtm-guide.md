# Real-time Messaging Guide

LeanCloud Real-time Messaging (RTM) Service allows you to make a full-featured real-time chat application without having to self-host a backend service. All of your messages are safely stored in the cloud. Offline messages will be delivered through Push Notifications Service ([APNs](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html) or [FCM](https://firebase.google.com/docs/cloud-messaging/)), and the content of a message is fully customizable.

To send a text message, you can simply do this:

```js
conversation.send(new AV.TextMessage('hey guys!'));
```

## Getting Started

### Compatibility

LeanCloud Real-time SDK for JavaScript can run on the following platforms (or browsers):

- Browsers/WebView
  - IE 10+
  - Edge latest
  - Chrome 45+
  - Firefox latest
  - iOS 9.3+
  - Android 4.4+
- Node.js 4.0+
- WeChat Mini-Program/Mini-Game latest
- React Native 0.26+
- Electron latest

### Install

Install SDK via NPM:

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
  appId: '{{appid}}',
  appKey: '{{appkey}}',
  region: 'us', // if in China set region to 'cn'
});
```

## Connecting

Use a **unique** id to connect to the cloud:

```js
// choose 'Tom' as the unique id
realtime.createIMClient('Tom').then(tom=> {
  // tom is an instance of AVIMClient
});
```

## Conversations

Once connected, clients can send and receive messages, which are tied to a specific `Conversation` object.

The following code shows how to create a conversation and send a text message:

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

If Jerry has logged in, he will be notified. For more details please check [Events.MEMBERS_JOINED](#Event.MEMBERS_JOINED).

### Fetching an Existing Conversation

Before sending messages to Jerry, Tom can check if there already is a conversation for Jerry and himself.

```js
tom.getQuery().containsMembers(['Jerry']).find().then(function(conversations) {
  // by default conversations are sorted by their last modified date (when the last message was received for each conversation) in descending order
  conversations.map(function(conversation) {
    console.log(conversation.lastMessageAt.toString(), conversation.members);
  });
}).catch(console.error.bind(console));
```

### Adding participants

A One-to-One Conversation can be transformed into a Group Conversation by engaging more participants.

```js
// fetch an existing Conversation which contains two members: ['Tom','Jerry']
conversation.add(['Mary']).then(function(conversation) {
  console.log('added', conversation.members);
  // now the conversation contains three members: ['Tom', 'Jerry','Mary']
}).catch(console.error.bind(console));
```
If Marry has logged in, she will get notified of being added to the Conversation. For more details please check [Events.MEMBERS_JOINED](#Event.MEMBERS_JOINED).

Please note that there is no logical difference between a One-to-One Conversation and a Group Conversation. Both of them are stored in the `_Conversation` class in the cloud and can be examined in your app's Dashboard.

### Unique Conversations

When creating a Conversation, you have the option to make it unique in the cloud by adding the "unique" parameter and setting it to `true`. That means once a Conversation has been created between User A and User B, any further attempts by either of these users to create a new Conversation with these participants will get resolved to the existing Conversation so that User A and User B may continue their Conversation.

```js
mary.createConversation({
  members: ['Tom', 'Jerry'],
  name: 'Party on weekends',
  unique: true,
});
```

Conversations default to **NOT being unique**, so multiple users can independently create multiple instances of Conversation with the same set of users. Let's see some examples:

```
var chat1 = mary.createConversation({
  members: ['Tom', 'Jerry'],
  unique: true,
});

var chat2 = mary.createConversation({
  members: ['Tom', 'Jerry'],
  unique: true,
});

var chat3 = mary.createConversation({
  members: ['Tom', 'Jerry'],
  unique: false,
});
```

In the above example

- **chat1** and **chat2** return the same Conversation.
- **topic1** and **chat3** are both newly created Conversations.

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

If Mary has logged in, she will be notified of being removed from the conversation. For more details please check [Event.KICKED](#Event.KICKED).


#### Managing Conversation Members

Let's say that Mary is going to invite Jerry and Tom to a party tonight, and there already is a Conversation between Jerry and Mary, Tom isn't part of it just yet.

Instead of inviting Tom to join the existing conversation, it is regarded as **a best practice** that Mary should create a new conversation and invite Jerry and Tom to join.

### Conversation Types

In addition to normal Conversations that can take up to 500 participants, our SDK also supports 2 other kinds of Conversation, which are  Chatroom and Service Account.

#### Chatroom

Supporting unlimited number of participants is a distinguishing characteristic of Chatroom that sets it apart from a normal conversation. However, for performance concerns, we recommend setting a limit of 5000 participants per chatroom. Chatrooms are transient by nature, meaning they don't persist once they are destroyed.

Chatrooms are suitable for live text broadcasting, such as live commenting feature where comments are rolling across the screen, and for discussion channels on hot topics.

To create a transient conversation for a live text broadcast of NBA, you can code like this:

```js
// createChatRoom is a shortcut method of creating transient conversations.
tom.createChatRoom({
  name: 'Raptors vs Spurs',
}).then(function(chatRoom) {
  console.log('Live channel created with id: ' + chatRoom.id);
}).catch(console.error.bind(console));
```

#### Service Account

Service-account Convesations are suitable for managing notices and system announcements. They can **only be created in the cloud** rather than on the client.

Here is the [curl](https://curl.haxx.se/) command to create a service-account conversation:

```sh
curl -X POST \
  -H "X-LC-Id: {{appid}}" \
  -H "X-LC-Key: {{appkey}}" \
  -H "Content-Type: application/json" \
  -d '{"name":"My First Service-conversation"}' \
  https://{{host}}/1.2/rtm/service-conversations
```

### Built-in Properties

A Conversation instance has the following built-in peroperties:

| Property Name      | _Conversation field |       Description            |
| --------------------- | ---------------- | -------------------------    |
| `id`                  | `objectId`       | conversation identity column              |
| `name`                | `name`           | conversation name            |
| `members`             | `m`              | member list                              |
| `creator`             | `c`              | creator of conversation                  |
| `transient`           | `tr`             | if a chatroom                                |
| `system`              | `sys`            | if a service conversation                    |
| `mutedMembers`        | `mu`             | members muted this conversation              |
| `muted`               | N/A              | if current client muted this conversation    |
| `createdAt`           | `createdAt`      | created timestamp                 |
| `updatedAt`           | `updatedAt`      | latest updated timestamp                   |
| `lastMessageAt`       | `lm`             | latest message timestamp |
| `lastMessage`         | N/A              | latest message             |
| `unreadMessagesCount` | N/A              | count of messages that haven't been read             |
| `lastDeliveredAt`     | N/A              | timestamp, when the last message was successfully delivered to the other participant  (supported only in one-to-one conversation)|
| `lastReadAt`          | N/A              | timestamp, when the message was last read by the other participant (one-to-one conversation only) |

#### Custom Properties

Add a Boolean property named `pinned` and a String property named `type`:

```js
tom.createConversation({
  members: ['Jerry'],
  name: 'Tom and Jerry',
  type: 'private',
  pinned: true,
}).then(function(conversation) {
  console.log('conversation successfully created. id: ' + conversation.id);
}).catch(console.error.bind(console));
```

## Querying

Get a conversation by `id`:

```js
tom.getConversation('put you conversation id here').then(function(conversation) {
  console.log(conversation.id);
}).catch(console.error.bind(console));
```

### Retrieving List of Conversations

```js
tom.getQuery().containsMembers(['Tom']).find().then(function(conversations) {
  conversations.map(function(conversation) {
    console.log(conversation.lastMessageAt.toString(), conversation.members);
  });
}).catch(console.error.bind(console));
```

Set the `limit` a count(less than 10000), then you can get conversation with the count:

```js
var query = tom.getQuery();
query.limit(20).containsMembers(['Tom']).find().then(function(conversations) {
  console.log(conversations.length);
}).catch(console.error.bind(console));
```

### Query Filters 

```js
// name equals to 'LeanCloud fans'
query.equalTo('name', 'LeanCloud fans');

// name contains 'LeanCloud' 的对话
query.contains('name', 'LeanCloud');

// messaged sent or properties updated in the last 24 hours
var yesterday = new Date(Date.now() - 24 * 3600 * 1000);
query.greaterThan('lm', yesterday);
```

For more filters, you can check the listed table here:

method|sample
--|--
notEqualTo|`query.notEqualTo('type','private')`
greaterThan|`query.greaterThan('age',18)`
lessThan|`query.lessThan('age',70)`
greaterThanOrEqualTo|`query.greaterThanOrEqualTo('age',45)`
lessThanOrEqualTo|`query.lessThanOrEqualTo('age',45)`

#### Regex Match

Find conversations with name is Chinese:

```js
query.matches('language',/[\\u4e00-\\u9fa5]/);
```

Before this query, you can set a conversation name a Chinese name 「开发者交流群」.

#### Contains

Find conversations with a string property named `keywords` contains 'education':

```js
query.contains('keywords','education');
```

Find conversation with some specific members:

```js
query.withMembers(['Bob', 'Jerry']);
```

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
  console.log('sent');
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
      console.log('text received: ' + message.getText() + ', msgId: ' + message.id);
      break;
    case FileMessage.TYPE:
      file = message.getFile(); // file 是 AV.File 实例
      console.log('file received with url: ' + file.url() + ', size: ' + file.metaData('size'));
      break;
    case ImageMessage.TYPE:
      file = message.getFile();
      console.log('image received with url: ' + file.url() + ', width: ' + file.metaData('width'));
      break;
    case AudioMessage.TYPE:
      file = message.getFile();
      console.log('audio received with url: ' + file.url() + ', width: ' + file.metaData('duration'));
      break;
    case VideoMessage.TYPE:
      file = message.getFile();
      console.log('video received with url: ' + file.url() + ', width: ' + file.metaData('duration'));
      break;
    case LocationMessage.TYPE:
      var location = message.getLocation();
      console.log('location received with latitude: ' + location.latitude + ', longitude: ' + location.longitude);
      break;
    default:
      console.warn('unknown message type received.');
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


## Message History Record Query

Get latest messages:

```js
conversation.queryMessages({
  limit: 10, // limit with a range from 1 to 1000
}).then(function(messages) {
}).catch(console.error.bind(console));
```

Load more messages by iterator:

```js
// create a message iterator,get 10 messages at a time
var messageIterator = conversation.createMessagesIterator({ limit: 10 });
// if there are more messages, result.done will be false
messageIterator.next().then(function(result) {
  // result: {
  //   value: [message1, ..., message10],
  //   done: false,
  // }
}).catch(console.error.bind(console));
messageIterator.next().then(function(result) {
  // result: {
  //   value: [message11, ..., message20],
  //   done: false,
  // }
}).catch(console.error.bind(console));
// if all the messages have been loaded, result.done will be true.
messageIterator.next().then(function(result) {
  // No more messages
  // result: { value: [message21], done: true }
}).catch(console.error.bind(console));
```

### Querying by message type

```js
conversation.queryMessages({ type: ImageMessage.TYPE }).then(messages => {
  console.log(messages);
}).catch(console.error);
```

## Logging Out

Log out or switch account:

```javascript
tom.close().then(function() {
  console.log('logged out');
}).catch(console.error.bind(console));
```
