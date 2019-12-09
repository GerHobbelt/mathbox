const fs = require('fs')
const glob = require('glob')
const path = require('path')

const SNIPPETS_PATH = `${__dirname}/snippets.json`

function importGLSL() {
  const snippets = glob.sync( `${__dirname}/glsl/**/*.glsl` )
  .reduce((acc, filePath) => {
    const fileName = path.basename(filePath, path.extname(filePath))
    acc[fileName] = fs.readFileSync(filePath, 'utf8')
    return acc;
  }, {}); 
  return snippets;
}

function buildFile() {
  const snippets = importGLSL()
  fs.writeFileSync(SNIPPETS_PATH, JSON.stringify(snippets))
}

buildFile()