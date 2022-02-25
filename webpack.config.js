const path = require('path')

module.exports = {
  devtool: 'cheap-module-source-map',
  entry: {
    main: ['./src/assets/css/main.css','./src/assets/js/main'],
  },
  output: {
    path: path.join(__dirname, 'dist/assets'),
    filename: 'main.js',
    chunkFilename: `[name]-[id].js?version=${Date.now()}`
  },
  module: {
    rules: [
      {
        enforce: "pre",
        test: /\.js$/,
        exclude: /node_modules/,
        loader: "eslint-loader",
      },
      {
        test: /\.js$/,
        use: [
          'babel-loader'
        ]
      },
      {
        test: /\.s?css$/,
        extract: true,
        use: [
          'style-loader',
          'css-loader?importLoaders=1',
          'postcss-loader'
        ]
      },
    ]
  },
  resolve: {
    alias: {
      'lib': path.resolve(__dirname, 'src/assets/js/lib'),
      'modules': path.resolve(__dirname, 'src/modules'),
      'root': path.resolve(__dirname, 'src'),
      'react': 'preact-compat',
      'react-dom': 'preact-compat'
    },
  },
  plugins: [],
}
