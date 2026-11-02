import { createReadStream, statSync } from 'node:fs'
import { createServer } from 'node:http'
import { extname, resolve, sep } from 'node:path'

const root = resolve(process.cwd(), 'dist')
const port = Number(process.env.PORT || 3000)
const types = {
  '.css': 'text/css; charset=utf-8',
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
}

if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error(`Invalid PORT: ${process.env.PORT}`)
if (!statSync(root).isDirectory()) throw new Error(`Static build directory not found: ${root}`)

createServer((request, response) => {
  let pathname
  try {
    pathname = decodeURIComponent(new URL(request.url, 'http://localhost').pathname)
  } catch {
    response.writeHead(400).end('Bad request')
    return
  }
  const relative = pathname === '/' ? 'index.html' : pathname.replace(/^\/+/, '')
  const file = resolve(root, relative)
  if (file !== root && !file.startsWith(`${root}${sep}`)) {
    response.writeHead(403).end('Forbidden')
    return
  }
  let target = file
  try {
    if (!statSync(target).isFile()) throw new Error('Not a file')
  } catch {
    if (!extname(pathname)) target = resolve(root, 'index.html')
    else {
      response.writeHead(404).end('Not found')
      return
    }
  }
  response.writeHead(200, { 'Content-Type': types[extname(target)] || 'application/octet-stream', 'Cache-Control': 'no-cache' })
  createReadStream(target).pipe(response)
}).listen(port, '0.0.0.0', () => console.log(`Serving ${root} on port ${port}`))
