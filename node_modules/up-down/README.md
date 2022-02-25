# up-down  [![npm](https://img.shields.io/npm/v/up-down.svg?maxAge=2592000)](https://www.npmjs.com/package/up-down)
A quantity selector written in ES6.

## Install 
```bash
npm i up-down --save
```

## Usage

#### Markup 
```html
<div class="counter">
  <button type="button" data-count="-"> - </button> 
  <input type="number" value="0" min="0" max="10">
  <button type="button" data-count="+"> + </button> 
</div>
```

#### Instantiate 
```javascript
import updown from 'up-down'

const el = document.getElementById('counter')
const counter = updown(el)

counter.on('change', (val) => console.log(val))
counter.on('min', (val) => console.log(val))
counter.on('max', (val) => console.log(val))
```

#### Style (optional)
See `dist/up-down.css` for styles, or style as you wish.

#### Destroy An Instance
Destroy an instance and all handlers.
```javascript
counter.destroy()
```

#### Get Count
The current count is always available on the instance.
```javascript
counter.count
```

## Dependencies
- [knot.js:](https://github.com/callmecavs/knot.js) A browser-based event emitter, for tying things together. By [@callmecavs](https://github.com/callmecavs)
- [closest:](https://github.com/ForbesLindesay/closest) Find the closest parent that matches a selector. By [@ForbesLindesay](https://github.com/ForbesLindesay)

## TODO
1. Allow user to pass min/max values to instance to override the native min/max attributes
2. Allow custom markup? Or at least give selector classes to allow markup to be changed.

### MIT License
