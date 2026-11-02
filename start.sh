#!/usr/bin/env bash
set -euo pipefail

# Build and serve a static preview. All project output remains under PROJECT_DIR.
PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)}"
cd "$PROJECT_DIR"
PROJECT_DIR="$(pwd -P)"
PORT="${PORT:-3000}"
[[ "$PORT" =~ ^[0-9]+$ ]] && (( PORT > 0 && PORT < 65536 )) || { echo 'PORT must be an integer from 1 to 65535.' >&2; exit 1; }
export PORT

BUILD_DIR="${BUILD_DIR:-$PROJECT_DIR/dist}"
case "$BUILD_DIR" in
  /*) ;;
  *) BUILD_DIR="$PROJECT_DIR/$BUILD_DIR" ;;
esac
case "$BUILD_DIR/" in
  "$PROJECT_DIR"/*) ;;
  *) echo 'BUILD_DIR must be inside PROJECT_DIR.' >&2; exit 1 ;;
esac

if [[ -f "$PROJECT_DIR/package.json" ]]; then
  if [[ -f "$PROJECT_DIR/package-lock.json" ]]; then
    /usr/bin/time -p npm ci --no-audit --no-fund
  elif [[ -f "$PROJECT_DIR/pnpm-lock.yaml" ]] && command -v pnpm >/dev/null 2>&1; then
    /usr/bin/time -p pnpm install --frozen-lockfile
  elif [[ -f "$PROJECT_DIR/yarn.lock" ]] && command -v yarn >/dev/null 2>&1; then
    /usr/bin/time -p yarn install --frozen-lockfile
  else
    /usr/bin/time -p npm install --no-audit --no-fund
  fi
  if /usr/bin/time -p node -e "const p=require('./package.json'); process.exit(p.scripts?.build ? 0 : 1)"; then
    /usr/bin/time -p npm run build
  fi
  [[ -f "$BUILD_DIR/index.html" ]] || { echo "Build output missing: $BUILD_DIR/index.html" >&2; exit 1; }
elif [[ ! -f "$BUILD_DIR/index.html" ]]; then
  /usr/bin/time -p mkdir -p "$BUILD_DIR"
  /usr/bin/time -p tee "$BUILD_DIR/index.html" >/dev/null <<'HTML'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="theme-color" content="#10120f">
<title>Wayfarer — An open-world action RPG</title>
<style>
:root{color-scheme:dark;--bg:#10120f;--panel:#191c17;--panel2:#20231d;--line:#34382f;--ink:#f2f0e7;--muted:#a6a99b;--lime:#d4f17a;--orange:#f5a66b;--serif:Georgia,'Times New Roman',serif}*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;background:var(--bg);color:var(--ink);font:15px/1.55 Inter,ui-sans-serif,system-ui,-apple-system,Segoe UI,sans-serif}a{color:inherit;text-decoration:none}button{font:inherit}.shell{max-width:1280px;margin:auto;padding:0 6.1%}.topbar{height:82px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #ffffff14}.brand{display:flex;align-items:center;gap:12px;font-size:15px;font-weight:800;letter-spacing:.13em}.sigil{width:29px;height:29px;border:1px solid var(--lime);color:var(--lime);display:grid;place-items:center;transform:rotate(45deg);font-family:var(--serif);font-size:19px}.sigil span{transform:rotate(-45deg)}nav{display:flex;gap:34px;color:#c5c6bb;font-size:13px}.nav-cta{border:1px solid #ffffff38;padding:10px 15px;border-radius:4px;font-size:12px;letter-spacing:.04em}.hero{min-height:570px;display:grid;grid-template-columns:1.04fr .96fr;align-items:center;gap:5%;padding-top:38px;padding-bottom:48px}.eyebrow{color:var(--lime);text-transform:uppercase;letter-spacing:.2em;font-size:10px;font-weight:800;display:flex;align-items:center;gap:10px}.eyebrow:before{content:'';width:25px;height:1px;background:var(--lime)}h1,h2,h3,p{margin-top:0}h1{font:clamp(54px,7vw,91px)/.91 var(--serif);letter-spacing:-.055em;font-weight:400;margin:23px 0 24px;max-width:600px}h1 em{color:var(--lime);font-weight:400}.intro{max-width:480px;color:#b9baaf;font-size:16px;line-height:1.8}.actions{display:flex;align-items:center;gap:22px;margin-top:30px}.button{background:var(--lime);color:#171a11;padding:13px 19px;border-radius:3px;font-weight:800;font-size:12px;letter-spacing:.04em}.text-link{color:#e4e3d8;font-size:12px}.text-link span{color:var(--lime);margin-left:7px}.world-card{height:405px;border:1px solid #d5ef7b38;border-radius:5px;position:relative;overflow:hidden;background:radial-gradient(ellipse at 53% 56%,#9b955045 0%,transparent 34%),radial-gradient(ellipse at 49% 53%,#536549 0%,transparent 47%),linear-gradient(145deg,#39473b,#1d2824 55%,#111613);box-shadow:0 25px 80px #0008}.world-card:before,.world-card:after{content:'';position:absolute;inset:0;background-image:linear-gradient(27deg,transparent 47%,#d1dd9b12 48%,transparent 49%),linear-gradient(153deg,transparent 48%,#d1dd9b10 49%,transparent 50%);background-size:95px 71px;opacity:.5}.world-card:after{inset:12% 18%;border:1px solid #d4f17a37;border-radius:50%;transform:rotate(-24deg);box-shadow:0 0 40px #d4f17a18}.sun{position:absolute;width:135px;height:135px;border-radius:50%;right:19%;top:12%;background:radial-gradient(circle,#edbd7e,#c9946955 55%,transparent 70%);filter:blur(1px)}.ridge{position:absolute;bottom:-1px;left:-4%;width:112%;height:62%;background:linear-gradient(155deg,#667252,#343f31 52%,#202720 53%);clip-path:polygon(0 56%,12% 31%,21% 47%,35% 10%,48% 51%,62% 22%,75% 48%,90% 16%,100% 42%,100% 100%,0 100%)}.ridge.back{bottom:22%;height:40%;opacity:.48;filter:brightness(.7);clip-path:polygon(0 70%,13% 22%,26% 62%,43% 0,58% 53%,73% 10%,88% 55%,100% 14%,100% 100%,0 100%)}.trail{position:absolute;z-index:2;bottom:-25%;left:44%;width:42%;height:66%;border-left:2px solid #d8cc9970;border-radius:50%;transform:rotate(28deg)}.map-label{position:absolute;z-index:4;font-size:9px;letter-spacing:.16em;color:#e5e4ce;text-transform:uppercase}.map-label.one{left:10%;top:20%}.map-label.two{right:9%;top:47%}.map-label.three{left:38%;bottom:16%;color:var(--lime)}.map-dot{position:absolute;z-index:5;left:48%;top:55%;width:8px;height:8px;border-radius:50%;background:var(--lime);box-shadow:0 0 0 7px #d4f17a33,0 0 19px var(--lime)}.map-caption{position:absolute;z-index:4;bottom:17px;left:19px;right:19px;display:flex;justify-content:space-between;align-items:end}.map-caption small{font-size:9px;letter-spacing:.16em;color:#d4f17a}.map-caption strong{display:block;font:22px var(--serif);font-weight:400}.map-coords{font-size:9px;color:#c1c6b3;letter-spacing:.1em}.stats{border-top:1px solid var(--line);border-bottom:1px solid var(--line);display:grid;grid-template-columns:repeat(4,1fr);padding:19px 0}.stat{padding:0 20px;border-right:1px solid var(--line)}.stat:first-child{padding-left:0}.stat:last-child{border:0}.stat b{display:block;font:22px var(--serif);font-weight:400;color:var(--ink)}.stat span{font-size:9px;color:var(--muted);letter-spacing:.14em;text-transform:uppercase}.section{padding:88px 0}.section-head{display:flex;justify-content:space-between;align-items:end;margin-bottom:27px}.section-head h2{font:clamp(34px,4vw,47px)/1.02 var(--serif);font-weight:400;letter-spacing:-.03em;margin:12px 0 0}.section-head p{max-width:320px;color:var(--muted);font-size:13px;margin:0}.class-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:12px}.class-card{min-height:283px;background:var(--panel);border:1px solid var(--line);padding:21px 19px;position:relative;overflow:hidden;transition:.2s}.class-card:hover,.class-card.active{border-color:#d4f17a82;transform:translateY(-3px)}.class-no{font-size:9px;letter-spacing:.13em;color:#85897c}.class-icon{margin:27px 0 15px;color:var(--lime);font-size:23px}.class-card:nth-child(2) .class-icon{color:#a7c7f5}.class-card:nth-child(3) .class-icon{color:#d39bf5}.class-card:nth-child(4) .class-icon{color:var(--orange)}.class-card h3{font:25px var(--serif);font-weight:400;margin:0 0 4px}.role{font-size:9px;text-transform:uppercase;letter-spacing:.13em;color:var(--muted)}.class-card p{font-size:12px;color:#b4b6aa;line-height:1.65;margin:15px 0 0;max-width:220px}.class-mark{position:absolute;right:13px;top:17px;font:45px var(--serif);color:#ffffff0b}.combat{display:grid;grid-template-columns:.87fr 1.13fr;gap:46px;align-items:center;padding-top:12px}.combat-art{height:328px;position:relative;overflow:hidden;border:1px solid #ffffff12;background:radial-gradient(ellipse at 49% 45%,#ecb87445,transparent 31%),linear-gradient(150deg,#333c2f,#171c19)}.combat-art:before{content:'';position:absolute;inset:0;background:linear-gradient(135deg,transparent 40%,#dbdca41a 41%,transparent 42%),linear-gradient(43deg,transparent 47%,#dbdca411 48%,transparent 49%);background-size:90px 70px}.moon{position:absolute;right:20%;top:13%;width:68px;height:68px;border-radius:50%;background:#dbd4a9;box-shadow:0 0 48px #e1d6a355}.fighter{position:absolute;z-index:2;width:12px;height:122px;left:49%;bottom:18%;background:#141713;border-radius:50% 50% 3px 3px;transform:rotate(10deg);box-shadow:0 -17px 0 -3px #d9c9a3}.fighter:before{content:'';position:absolute;width:90px;height:2px;background:linear-gradient(90deg,transparent,var(--lime),transparent);top:34px;left:-39px;transform:rotate(-38deg);box-shadow:0 0 18px var(--lime)}.fighter:after{content:'';position:absolute;height:34px;width:2px;background:#d9d3be;top:48px;left:2px;transform:rotate(28deg)}.enemy{position:absolute;right:24%;bottom:20%;width:13px;height:65px;background:#422923;border-radius:50% 50% 0 0;box-shadow:0 -11px 0 -2px #d4775d}.ground{position:absolute;bottom:0;height:29%;width:100%;background:linear-gradient(#697052,#242b22);clip-path:polygon(0 40%,19% 23%,41% 41%,61% 13%,83% 35%,100% 19%,100% 100%,0 100%)}.art-tag{position:absolute;top:17px;left:17px;font-size:8px;letter-spacing:.16em;color:#d7e89d;text-transform:uppercase}.combat-copy h2{font:43px/1.04 var(--serif);font-weight:400;letter-spacing:-.04em;margin:14px 0}.combat-copy>p{color:var(--muted);font-size:13px;max-width:430px}.feature-list{list-style:none;padding:0;margin:24px 0}.feature-list li{border-top:1px solid var(--line);padding:11px 0;font-size:12px;color:#d9dbcf;display:flex;justify-content:space-between}.feature-list span{font-size:10px;color:var(--lime)}.bottom-band{background:var(--panel);border:1px solid var(--line);padding:26px 30px;display:flex;justify-content:space-between;align-items:center;margin-bottom:70px}.bottom-band h3{font:24px var(--serif);font-weight:400;margin:0}.bottom-band p{margin:4px 0 0;color:var(--muted);font-size:12px}.footer{border-top:1px solid var(--line);padding:22px 0 30px;color:#85897c;font-size:10px;display:flex;justify-content:space-between;letter-spacing:.04em}.footer strong{color:#d4f17a;letter-spacing:.14em}.mobile-menu{display:none}
@media(max-width:800px){.shell{padding:0 5%}.topbar{height:68px}nav{gap:16px}.nav-cta{display:none}.hero{grid-template-columns:1fr;padding-top:55px;gap:34px}.hero-copy{max-width:620px}.world-card{height:310px}.stats{grid-template-columns:repeat(2,1fr);gap:17px 0}.stat:nth-child(2){border:0}.stat:nth-child(3){padding-left:0}.section{padding:64px 0}.class-grid{grid-template-columns:repeat(2,1fr)}.combat{grid-template-columns:1fr;gap:25px}.combat-art{height:290px}.section-head{align-items:start;gap:17px;flex-direction:column}.bottom-band{margin-bottom:45px}}
@media(max-width:480px){body{font-size:14px}.shell{padding:0 20px}.brand{font-size:13px}.sigil{width:25px;height:25px}nav{gap:13px;font-size:11px}.hero{min-height:0;padding:48px 0 30px;gap:29px}h1{font-size:62px;margin:18px 0}.intro{font-size:14px}.actions{gap:17px}.world-card{height:258px}.sun{width:100px;height:100px}.stats{padding:16px 0}.stat{padding:0 13px}.stat b{font-size:19px}.stat span{font-size:8px}.section{padding:52px 0}.section-head h2{font-size:36px}.class-grid{gap:8px}.class-card{padding:16px 13px;min-height:255px}.class-icon{margin:22px 0 12px}.class-card h3{font-size:23px}.class-card p{font-size:11px}.combat-art{height:245px}.combat-copy h2{font-size:37px}.bottom-band{padding:20px;align-items:flex-start;gap:16px;flex-direction:column}.footer{gap:8px;flex-direction:column}}
</style>
</head>
<body>
<header class="shell topbar"><a class="brand" href="#top"><span class="sigil"><span>✦</span></span> WAYFARER</a><nav aria-label="Main navigation"><a href="#world">The world</a><a href="#classes">Adventurers</a><a href="#combat">Combat</a></nav><a class="nav-cta" href="#classes">EXPLORE THE REALMS ↗</a></header>
<main>
<section class="shell hero" id="top"><div class="hero-copy"><div class="eyebrow">A living world awaits</div><h1>Find your<br><em>own way.</em></h1><p class="intro">Beyond the old kingdom, a wild frontier is waking. Follow forgotten paths, master a fighting style, and write your legend one encounter at a time.</p><div class="actions"><a class="button" href="#world">ENTER THE FRONTIER&nbsp; ↗</a><a class="text-link" href="#classes">Meet the adventurers <span>→</span></a></div></div><div class="world-card" id="world" role="img" aria-label="Illustrated map of the Verdant Reach at dusk"><div class="sun"></div><div class="ridge back"></div><div class="ridge"></div><div class="trail"></div><span class="map-label one">Mossfall Vale</span><span class="map-label two">The Old March</span><span class="map-label three">✦ &nbsp; Wayfarer’s Rest</span><i class="map-dot"></i><div class="map-caption"><div><small>FIELD NOTES&nbsp; / &nbsp;01</small><strong>The Verdant Reach</strong></div><span class="map-coords">N 42° 18′ &nbsp; E 07° 26′</span></div></div></section>
<section class="shell stats" aria-label="World overview"><div class="stat"><b>04</b><span>Distinct paths</span></div><div class="stat"><b>∞</b><span>Roads to wander</span></div><div class="stat"><b>01–04</b><span>Travel together</span></div><div class="stat"><b>Yours</b><span>Choose your pace</span></div></section>
<section class="shell section" id="classes"><div class="section-head"><div><div class="eyebrow">Choose your path</div><h2>Every legend starts somewhere.</h2></div><p>Four combat disciplines. No single road through the wild. Find the rhythm that feels like yours.</p></div><div class="class-grid"><article class="class-card"><span class="class-no">PATH 01&nbsp; / &nbsp;VANGUARD</span><div class="class-icon">✧</div><h3>Swordsman</h3><div class="role">Melee · Guard · Counter</div><p>Hold the line. Turn a perfect block into a punishing answer.</p><span class="class-mark">Ⅰ</span></article><article class="class-card"><span class="class-no">PATH 02&nbsp; / &nbsp;ARcanist</span><div class="class-icon">✳</div><h3>Wizard</h3><div class="role">Elements · Control · Burst</div><p>Shape the battlefield with elemental force and a mana ward.</p><span class="class-mark">Ⅱ</span></article><article class="class-card"><span class="class-no">PATH 03&nbsp; / &nbsp;SHADE</span><div class="class-icon">⌁</div><h3>Ninja</h3><div class="role">Mobility · Stealth · Critical</div><p>Disappear, strike from the blind spot, and let shadows follow.</p><span class="class-mark">Ⅲ</span></article><article class="class-card"><span class="class-no">PATH 04&nbsp; / &nbsp;RANGER</span><div class="class-icon">➶</div><h3>Archer</h3><div class="role">Range · Traps · Precision</div><p>Keep moving, set the snare, and let one arrow find them all.</p><span class="class-mark">Ⅳ</span></article></div></section>
<section class="shell combat" id="combat"><div class="combat-art" role="img" aria-label="An adventurer faces a foe beneath the evening moon"><span class="art-tag">FIELD ENCOUNTER&nbsp; / &nbsp;NO. 07</span><span class="moon"></span><span class="fighter"></span><span class="enemy"></span><span class="ground"></span></div><div class="combat-copy"><div class="eyebrow">Read the moment</div><h2>Quick hands.<br>Thoughtful choices.</h2><p>Every fight is a conversation: watch for an opening, spend your strength wisely, and use the terrain. Your class changes the answer—not the need to pay attention.</p><ul class="feature-list"><li>Responsive action combat <span>01</span></li><li>Class-defining signature skills <span>02</span></li><li>Challenges that grow with you <span>03</span></li></ul></div></section>
<section class="shell bottom-band"><div><h3>The road keeps going.</h3><p>Grow beyond the horizon—without leaving your old victories behind.</p></div><a class="button" href="#top">SET OUT&nbsp; ↗</a></section>
</main><footer class="shell footer"><span><strong>WAYFARER</strong> &nbsp; AN OPEN-WORLD ACTION RPG</span><span>WANDER WELL. LEAVE A LIGHT ON.</span></footer>
</body></html>
HTML
fi

[[ -f "$BUILD_DIR/index.html" ]] || { echo "Static directory has no index.html: $BUILD_DIR" >&2; exit 1; }
OPENCODE_WEB_DIR="${OPENCODE_WEB_DIR:-$PROJECT_DIR/.opencode-web}"
/usr/bin/time -p mkdir -p "$OPENCODE_WEB_DIR"
/usr/bin/time -p node - "$OPENCODE_WEB_DIR/deployment-output.json" "$PROJECT_DIR" "$BUILD_DIR" <<'NODE'
const fs = require('node:fs')
const path = require('node:path')
const [file, project, directory] = process.argv.slice(2)
fs.writeFileSync(file, JSON.stringify({ project: path.resolve(project), directory: path.resolve(directory) }))
NODE

/usr/bin/time -p node - "$BUILD_DIR" "$PORT" <<'NODE'
const fs = require('node:fs')
const path = require('node:path')
const http = require('node:http')
const root = path.resolve(process.argv[2])
const port = Number(process.argv[3])
const types = { '.html':'text/html; charset=utf-8', '.css':'text/css; charset=utf-8', '.js':'text/javascript; charset=utf-8', '.json':'application/json; charset=utf-8', '.svg':'image/svg+xml', '.png':'image/png', '.jpg':'image/jpeg', '.jpeg':'image/jpeg', '.webp':'image/webp', '.ico':'image/x-icon', '.woff2':'font/woff2' }
http.createServer((req, res) => {
  let pathname
  try { pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname) } catch { res.writeHead(400).end('Bad request'); return }
  let file = path.resolve(root, `.${pathname}`)
  if (file !== root && !file.startsWith(root + path.sep)) { res.writeHead(403).end('Forbidden'); return }
  try { if (fs.statSync(file).isDirectory()) file = path.join(file, 'index.html') }
  catch { file = path.join(root, 'index.html') }
  fs.readFile(file, (error, data) => {
    if (error) { res.writeHead(404).end('Not found'); return }
    res.writeHead(200, { 'Content-Type': types[path.extname(file).toLowerCase()] || 'application/octet-stream', 'Cache-Control': 'no-cache' })
    res.end(req.method === 'HEAD' ? undefined : data)
  })
}).listen(port, '0.0.0.0', () => console.log(`Serving ${root} on port ${port}`))
NODE
