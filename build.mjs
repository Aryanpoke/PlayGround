import { cp, mkdir, rm } from 'node:fs/promises'
import { resolve } from 'node:path'

const root = process.cwd()
const source = resolve(root, 'src')
const output = resolve(root, 'dist')
if (!source.startsWith(`${root}/`) || !output.startsWith(`${root}/`)) {
  throw new Error('Source and build output must remain inside the project directory.')
}
await rm(output, { recursive: true, force: true })
await mkdir(output, { recursive: true })
await cp(source, output, { recursive: true })
console.log(`Built static site: ${output}`)
