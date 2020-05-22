const path = require('path')

const mode = process.env.NODE_ENV === 'development'
  ? 'development'
  : 'production'
const buildPath = path.resolve(__dirname, 'build')

const sharedConfig = {
  mode,
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: [ 'coffee-loader' ]
      },
      {
        test:/\.css$/,
        use:['style-loader','css-loader']
    }
    ]
  },
  resolve: {
    extensions: [ '.js', '.coffee' ]
  },
  optimization: {
    // We no not want to minimize our code.
    minimize: false
  }
}

const nodeBuild = {
  entry: './src/index.coffee',
  output: {
    filename: `mathbox.commonjs2.js`,
    library: 'MathBox',
    libraryTarget: 'commonjs2',
    path: buildPath
  },
  ...sharedConfig
}
const scriptBuild = {
  entry: './src/index.var.coffee',
  output: {
    filename: `mathbox-bundle.js`,
    libraryTarget: 'var',
    path: buildPath
  },
  ...sharedConfig
}

module.exports = [
  nodeBuild,
  scriptBuild
]