(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.upDown = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (el) {
  var input = el.getElementsByTagName('input')[0];
  var min = input.getAttribute('min') ? parseInt(input.getAttribute('min'), 10) : 0;
  var max = input.getAttribute('max') ? parseInt(input.getAttribute('max'), 10) : 9999;

  var instance = Object.create((0, _knot2.default)({
    min: min,
    max: max,
    destroy: destroy
  }), {
    value: {
      value: clamp(parseInt(input.value, 10)),
      writable: true
    }
  });

  var state = {
    store: {
      value: instance.value
    },
    set value(val) {
      val = typeof val === 'number' ? val : min;
      this.store.value = val;
      input.value = val;
      instance.value = val;
    },
    get value() {
      return this.store.value;
    }
  };

  function emit(val) {
    if (!instance) return;

    if (val === min) emit('min', val);
    if (val === max) emit('max', val);

    instance.emit('change', val);
  }

  function clamp(val) {
    var _val = void 0;

    if (val >= min && val <= max) {
      _val = val;
    } else if (val >= max) {
      _val = max;
    } else if (val <= min) {
      _val = min;
    }

    emit(_val);

    return _val;
  }

  function clickHandler(e) {
    var target = (0, _closest2.default)(e.target, 'button', true);
    var type = target.getAttribute('data-count');
    var val = type === '+' ? 1 : -1;

    state.value = clamp(state.value + val);
  }

  function changeHandler(e) {
    state.value = clamp(parseInt(e.target.value, 10));
  }

  function destroy() {
    el.removeEventListener('click', clickHandler);
    input.removeEventListener('change', changeHandler);
    instance.off('min');
    instance.off('max');
    instance.off('change');
  }

  el.addEventListener('click', clickHandler);

  input.addEventListener('change', changeHandler);

  return instance;
};

var _closest = require('closest');

var _closest2 = _interopRequireDefault(_closest);

var _knot = require('knot.js');

var _knot2 = _interopRequireDefault(_knot);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

},{"closest":2,"knot.js":3}],2:[function(require,module,exports){
var matches = require('matches-selector')

module.exports = function (element, selector, checkYoSelf) {
  var parent = checkYoSelf ? element : element.parentNode

  while (parent && parent !== document) {
    if (matches(parent, selector)) return parent;
    parent = parent.parentNode
  }
}

},{"matches-selector":4}],3:[function(require,module,exports){
/*!
 * Knot.js 1.1.1 - A browser-based event emitter, for tying things together.
 * Copyright (c) 2016 Michael Cavalea - https://github.com/callmecavs/knot.js
 * License: MIT
 */
!function(n,e){"object"==typeof exports&&"undefined"!=typeof module?module.exports=e():"function"==typeof define&&define.amd?define(e):n.Knot=e()}(this,function(){"use strict";var n={};n["extends"]=Object.assign||function(n){for(var e=1;e<arguments.length;e++){var t=arguments[e];for(var r in t)Object.prototype.hasOwnProperty.call(t,r)&&(n[r]=t[r])}return n};var e=function(){function e(n,e){return f[n]=f[n]||[],f[n].push(e),this}function t(n,t){return t._once=!0,e(n,t),this}function r(n){var e=arguments.length<=1||void 0===arguments[1]?!1:arguments[1];return e?f[n].splice(f[n].indexOf(e),1):delete f[n],this}function o(n){for(var e=this,t=arguments.length,o=Array(t>1?t-1:0),i=1;t>i;i++)o[i-1]=arguments[i];var u=f[n]&&f[n].slice();return u&&u.forEach(function(t){t._once&&r(n,t),t.apply(e,o)}),this}var i=arguments.length<=0||void 0===arguments[0]?{}:arguments[0],f={};return n["extends"]({},i,{on:e,once:t,off:r,emit:o})};return e});
},{}],4:[function(require,module,exports){

/**
 * Element prototype.
 */

var proto = Element.prototype;

/**
 * Vendor function.
 */

var vendor = proto.matchesSelector
  || proto.webkitMatchesSelector
  || proto.mozMatchesSelector
  || proto.msMatchesSelector
  || proto.oMatchesSelector;

/**
 * Expose `match()`.
 */

module.exports = match;

/**
 * Match `el` to `selector`.
 *
 * @param {Element} el
 * @param {String} selector
 * @return {Boolean}
 * @api public
 */

function match(el, selector) {
  if (vendor) return vendor.call(el, selector);
  var nodes = el.parentNode.querySelectorAll(selector);
  for (var i = 0; i < nodes.length; ++i) {
    if (nodes[i] == el) return true;
  }
  return false;
}
},{}]},{},[1])(1)
});