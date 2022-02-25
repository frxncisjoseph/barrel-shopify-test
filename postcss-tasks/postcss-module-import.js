const path = require('path')
const postcss = require('postcss')
const postcssImport = require('postcss-import')
const globby = require('globby')
const postcssImportResolve = require('postcss-import/lib/resolve-id')

const resolve = (id, base, options) => {
  if (id !== '<Modules>') {
    return postcssImportResolve(id, base, options)
  }

  const modules = process.cwd() + '/src/modules/**/**.css'

  return globby(modules)
    .then(files => {
      return files
        .sort((a, b) => {
          const aFileName = a.replace('.css', '').split('/').pop().toLowerCase()
          const bFileName = b.replace('.css', '').split('/').pop().toLowerCase()

          if (aFileName > bFileName) { return 1 }
          if (aFileName < bFileName) { return -1 }
          return 0
        })
        .map(f => path.normalize(f))
    })
}

const init = (opts = {}) => {
  opts.resolve = resolve
  return postcss([postcssImport(opts)])
}

module.exports = postcss.plugin('postcss-module-import', init)
