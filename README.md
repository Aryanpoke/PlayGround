# Infinite Realms — Shattered Frontier

A small, self-contained browser prototype based on the Infinite Realms GDD. This is a local single-player vertical slice, not a production online RPG.

## Run

Open `index.html` in a modern browser, or serve this directory locally:

```sh
python3 -m http.server 3002
```

Then visit <http://localhost:3002>.

## Play

- **Move:** WASD / arrow keys; on touch, tap an empty spot in the world to move there.
- **Aim and attack:** hold the left mouse button; on touch, tap a nearby creature to strike.
- **Combat arts:** keys **1–4** (cost energy, with cooldowns).
- **Dodge:** Space.
- **Level up:** choose an attribute in the level-up modal. The Auto toggle allocates attributes automatically; click a combat art to spend a skill point and upgrade it.
- **Class:** switch between Swordsman, Wizard, Ninja, and Archer from the class selector.

The prototype includes top-down combat, enemy drops across the stated rarity tiers, XP and level-ups, basic class-specific skills, responsive layout, and touch-friendly movement. Multiplayer/cross-play, server-authoritative PvP, persistent saves, full skill-tree branches, and production-scale level balancing are not implemented.
