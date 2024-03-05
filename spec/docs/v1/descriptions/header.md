### Vedoc API Documentation

#### Category enum ####
> * Mechanic Shops => 0
> * Car Washes/Detail => 1
> * Performance Shop => 2
> * Tire/Wheel Shop => 3
> * Window Tint => 4
> * Auto Customization => 5
> * Car Stereo Installation => 6
> * Boat/Jet Ski Repair => 7
> * Electric Vehicle Charging Station => 8
> * Exhaust Shop/Muffler Shop => 9
> * Auto Paint => 10
> * Independent Mechanic => 11
> * Auto Parts and Suppliers => 12
> * Auto Glass Services => 13
> * Windshield installation Repair => 14
> * Towing => 15
> * Auto Upholstery => 16
> * Vehicle Transportation => 17
> * Pre Purchase Inspection => 18
> * Motorcycle Repair => 19
> * Vehicle Rental => 20
> * Auto Locksmith => 21

#### Service Request Status enum ####
> * Pending => 0
> * In Repair => 1
> * Done => 2

#### Available Device platforms ####
> * "android", "ios"

#### Push Notifications Payload
** Reminder **
```js
{ type: 'reminder' }
```

** New Message **
```js
{
  type: 'new_message',
  message: {
    created_at: "2019-03-21T10:37:41.000Z",
    from_id: 1,
    from_type: "Shop",
    message: "Test",
    offer_id: 1,
    service_request_id: 1,
    read: false,
    to_id: 1,
    to_type: "Client",
    _id: "5c8be40eeb39ac001162655b"
  }
}
```

** Hire **
```js
{ type: 'hire', service_request_id: 1 }
```

** New Offer **
```js
{ type: 'new_offer', service_request_id: 1, offer_id: 1 }
```

** New Offer Photos **
```js
{ type: 'new_offer_photos', service_request_id: 1, offer_id: 1 }
```

** New Service Request **
```js
{ type: 'new_service_request', service_request_id: 1 }
```

#### Socket Server Requests

** Connection to WS server **
```js
var socket = io.connect('http://localhost:8080', {
  query: {
    "access-token": "7_GTwyNVUd30wlBgURU6gw",
    "client": "0WrdVjr1gpFxdpgw11M4HA",
    "token-type": "Bearer",
    "uid": "sharonaufderhar@kertzmannkshlerin.name"
  }
});
```

** Success Connection **
```js
socket.on('connect', function() {
  // ...
})
```

** Join a room **
```js
socket.emit('joinRoom', { offer_id: 1 }, function(response) {
    console.log(response)
});
```

Success Response Example:
```json
{
  status: 'success',
  last_page: true,
  messages: [
    {
      created_at: "2019-03-21T10:37:41.000Z",
      from_id: 1,
      from_type: "Shop",
      message: "Test",
      offer_id: 1,
      service_request_id: 1,
      read: false,
      to_id: 1,
      to_type: "Client",
      _id: "5c8be40eeb39ac001162655b"
    }
  ],
  recepient: {
    accountable_id: 1,
    accountable_type: "Client",
    avatar: null,
    name: "amet",
  }
}
```

Error Response Example:
```json
{
  status: 'error',
  error: 'You do not have enough permissions to join to the room'
}
```

** Leave a room **
```js
socket.emit('leaveRoom', { offer_id: 1 }, function(response) {
    console.log(response)
});
```

Success Response Example:
```json
{
  status: 'success',
  message: 'Successfully left the room'
}
```

Error Response Example:
```json
{
  status: 'error',
  error: "Cannot leave 'room1'"
}
```

** Send a message **
```js
socket.emit('input', { message: textarea.value}, function(response) {
  console.log(response)
});
```

Success Response Example:
```json
{
  status: 'success',
  message: {
    created_at: "2019-03-21T10:37:41.000Z",
    from_id: 1,
    from_type: "Shop",
    message: "Test",
    offer_id: 1,
    service_request_id: 1,
    read: false,
    to_id: 1,
    to_type: "Client",
    _id: "5c8be40eeb39ac001162655b",
  }
}
```

Error Response Example:
```json
{ status: 'error', error: 'Invalid message params' }
```

** Get messages **
```js
socket.emit('getMessages', { id: '5c9ca58e0e1d600018ee8af6' }, function(response) {
  console.log(response)
});
```

Success Response Example:
```json
{
  status: 'success',
  last_page: true,
  messages: [{
    created_at: "2019-03-21T10:37:41.000Z",
    from_id: 1,
    from_type: "Shop",
    message: "Test",
    offer_id: 1,
    service_request_id: 1,
    read: false,
    to_id: 1,
    to_type: "Client",
    _id: "5c8be40eeb39ac001162655b",
  }]
}
```

Error Response Example:
```json
{ status: 'error', error: 'You have not joined to the room' }
```

#### Socket Server Events

** Unread messages (after successfull connection to WS server) **
```js
socket.on('unreadMessages', function(data) {
  console.log('Unread Messages', data)
})
```

Response Example:
```json
[
  { 
    count: 4,
    offer_id: 1,
    service_request_id: 1
  }
]
```

** New Message Inside a Room **
```js
socket.on('newRoomMessage', function(message) {
    console.log('New Room Message', message)
});
```

Response Example:
```json
{
  created_at: "2019-03-21T10:37:41.000Z",
  from_id: 1,
  from_type: "Shop",
  message: "Test",
  offer_id: 1,
  service_request_id: 1,
  read: false,
  to_id: 1,
  to_type: "Client",
  _id: "5c8be40eeb39ac001162655b",
}
```

** New Message with WS connection **
```js
socket.on('newMessage', function(message) {
    console.log('New Message', message)
})
```

Response Example:
```json
{
  created_at: "2019-03-21T10:37:41.000Z",
  from_id: 1,
  from_type: "Shop",
  message: "Test",
  offer_id: 1,
  service_request_id: 1,
  read: false,
  to_id: 1,
  to_type: "Client",
  _id: "5c8be40eeb39ac001162655b",
}
```

