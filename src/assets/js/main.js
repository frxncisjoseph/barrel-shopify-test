__webpack_public_path__ = BRRL_PATH(BRRL_PUBLIC_PATH) // eslint-disable-line camelcase

import 'lazysizes/plugins/object-fit/ls.object-fit'
import 'lazysizes/plugins/parent-fit/ls.parent-fit'
import 'lazysizes/plugins/rias/ls.rias'
import 'lazysizes/plugins/bgset/ls.bgset'
import 'lazysizes'
import 'lazysizes/plugins/respimg/ls.respimg'

import init from 'lib/init'
import { set, unset, toggle, isMobile } from 'lib/util'

document.addEventListener('DOMContentLoaded', () => {
  document.documentElement.className = document.documentElement.className.replace(/\bno-js\b/, 'js')
  init({
    module: 'modules'
  }).mount()
})
