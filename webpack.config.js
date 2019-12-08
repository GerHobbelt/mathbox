const path = require('path');

module.exports = {
  entry: './src/index.coffee',
  mode: 'production',
  output: {
    filename: `mathbox.js`,
    path: path.resolve(__dirname, 'build'),
  },
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: [ 'coffee-loader' ]
      },
      {
        test: /\.(glsl|vs|fs|vert|frag)$/,
        exclude: /node_modules/,
        use: [
          'raw-loader',
          'glslify-loader'
        ]
      }
    ]
  },
  resolve: {
    extensions: [ '.js', '.coffee' ]
  }
}