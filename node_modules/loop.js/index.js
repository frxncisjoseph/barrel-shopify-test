export default (o = {}) => {
  const listeners = {}

  const on = (e, cb = null) => {
    if (!cb) return
    listeners[e] = listeners[e] || { queue: [] }
    listeners[e].queue.push(cb)
  }

  const emit = (e, data = null) => {
    let items = listeners[e] ? listeners[e].queue : false
    items && items.forEach(i => i(data))
  }

  return {
    ...o,
    emit,
    on
  }
}
