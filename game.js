const classes = [
  { id:'guardian', name:'Guardian', title:'THE IRONBOUND', icon:'⚔', color:'#d5a866', glow:'rgba(191,133,67,.4)', description:'A steadfast shield against the dark. Endure every blow and answer with steel.', hp:130, mp:42, attack:18, skill:'Shieldbreak', skillLabel:'Heavy strike · 8 focus', skillCost:8, skillPower:31, hpStat:5, mpStat:2 },
  { id:'arcanist', name:'Arcanist', title:'THE STAR WEAVER', icon:'✧', color:'#aaa3df', glow:'rgba(128,109,190,.4)', description:'An adept of forgotten magic. Unleash a storm of arcane power at a cost.', hp:88, mp:72, attack:14, skill:'Starfall', skillLabel:'Arcane burst · 15 focus', skillCost:15, skillPower:43, hpStat:3, mpStat:5 },
  { id:'ranger', name:'Ranger', title:'THE WILDSWORN', icon:'➶', color:'#a2bd82', glow:'rgba(108,150,78,.4)', description:'A keen-eyed hunter who moves unseen and strikes before danger draws near.', hp:105, mp:56, attack:17, skill:'Quickshot', skillLabel:'Double arrow · 10 focus', skillCost:10, skillPower:34, hpStat:4, mpStat:3 }
];
const encounters = [
  {name:'Ashen Wolf', type:'WILD BEAST', icon:'🐺', hp:64, attack:10, xp:25, gold:12, intro:'An Ashen Wolf blocks your path. What will you do?'},
  {name:'Hollow Sentinel', type:'ANCIENT GUARDIAN', icon:'🗿', hp:91, attack:13, xp:35, gold:20, intro:'A Hollow Sentinel rises from the ruins, runes glowing.'},
  {name:'Cinder Drake', type:'THE MOUNTAIN’S WRATH', icon:'🐉', hp:125, attack:16, xp:55, gold:35, intro:'The Cinder Drake unfurls its wings. This is your final trial.'}
];
const $ = id => document.getElementById(id);
let selected = null, player = null, encounterIndex = 0, enemyHp = 0, enemyMax = 0, busy = false, logTimer;

function renderClasses(){
  $('class-grid').innerHTML = classes.map((item,index)=>`<article class="class-card" role="button" tabindex="0" aria-pressed="false" data-class="${item.id}" style="--class-color:${item.color};--class-glow:${item.glow}">
    <div class="card-top"><span class="class-number">0${index+1} / PATH</span><span class="class-icon" aria-hidden="true">${item.icon}</span></div>
    <h2>${item.name}</h2><div class="class-subtitle">${item.title}</div><p class="class-description">${item.description}</p>
    <div class="stat-row"><div class="mini-stat"><div class="mini-stat-label"><span>VITALITY</span><span>${item.hp}</span></div><div class="mini-bar"><span style="width:${item.hp/140*100}%"></span></div></div><div class="mini-stat"><div class="mini-stat-label"><span>FOCUS</span><span>${item.mp}</span></div><div class="mini-bar"><span style="width:${item.mp/80*100}%"></span></div></div></div><span class="class-select-indicator" aria-hidden="true">✓</span>
  </article>`).join('');
  document.querySelectorAll('.class-card').forEach(card=>{
    card.addEventListener('click',()=>selectClass(card.dataset.class));
    card.addEventListener('keydown',event=>{if(event.key==='Enter'||event.key===' '){event.preventDefault();selectClass(card.dataset.class)}});
  });
}
function selectClass(id){
  selected=classes.find(item=>item.id===id);
  document.querySelectorAll('.class-card').forEach(card=>{const active=card.dataset.class===id;card.classList.toggle('selected',active);card.setAttribute('aria-pressed',String(active))});
  $('begin-button').disabled=false;
}
function beginJourney(){
  if(!selected)return;
  player={...selected,currentHp:selected.hp,currentMp:selected.mp,potions:2,xp:0,level:1,gold:0};
  encounterIndex=0;busy=false;
  $('select-screen').hidden=true;$('game-screen').hidden=false;
  $('hero-name').textContent=player.name;$('hero-class').textContent=player.title;
  $('hero-medallion').textContent=player.icon;
  $('hero-panel').style.setProperty('--class-color',player.color);
  $('skill-name').textContent=player.skill.toUpperCase();$('skill-cost').textContent=player.skillLabel;
  loadEncounter();updatePlayer();window.scrollTo({top:0,behavior:'smooth'});
}
function loadEncounter(){
  const enemy=encounters[encounterIndex];enemyHp=enemyMax=enemy.hp;
  $('encounter-title').textContent=encounterIndex===0?'A shadow stirs':encounterIndex===1?'The ruins awaken':'The final trial';
  $('journey-count').innerHTML=`ENCOUNTER 0${encounterIndex+1} <span>—</span> 03`;
  $('enemy-type').textContent=enemy.type;$('enemy-name').textContent=enemy.name;$('enemy-art').textContent=enemy.icon;
  $('enemy-hp-label').textContent=`${enemyHp} / ${enemyMax}`;$('enemy-hp-fill').style.width='100%';
  setLog(enemy.intro);setActions(true);
}
function updatePlayer(){
  $('hero-level').textContent=String(player.level).padStart(2,'0');$('hero-xp').textContent=player.xp;
  const target=player.level*40;$('xp-next').textContent=target;$('xp-fill').style.width=`${Math.min(100,player.xp/target*100)}%`;
  $('hero-hp-label').textContent=`${player.currentHp} / ${player.hp}`;$('hero-hp-fill').style.width=`${Math.max(0,player.currentHp/player.hp*100)}%`;
  $('hero-mp-label').textContent=`${player.currentMp} / ${player.mp}`;$('hero-mp-fill').style.width=`${Math.max(0,player.currentMp/player.mp*100)}%`;
  $('hero-gold').textContent=player.gold;$('hero-potions').textContent=player.potions;
  $('potion-button').disabled=busy||player.potions<=0||player.currentHp>=player.hp;
  $('skill-button').disabled=busy||player.currentMp<player.skillCost;
  $('attack-button').disabled=busy;
}
function setActions(enabled){busy=!enabled;updatePlayer()}
function setLog(message){$('log-text').textContent=message}
function damageEnemy(amount){
  enemyHp=Math.max(0,enemyHp-amount);$('enemy-hp-label').textContent=`${enemyHp} / ${enemyMax}`;$('enemy-hp-fill').style.width=`${enemyHp/enemyMax*100}%`;
  const art=$('enemy-art');art.classList.remove('hit');void art.offsetWidth;art.classList.add('hit');
}
function attack(){if(busy)return;setActions(false);const damage=player.attack+Math.floor(Math.random()*7);damageEnemy(damage);setLog(`You strike the ${encounters[encounterIndex].name} for ${damage} damage.`);afterPlayerAction()}
function useSkill(){if(busy||player.currentMp<player.skillCost)return;setActions(false);player.currentMp-=player.skillCost;const damage=player.skillPower+Math.floor(Math.random()*8);damageEnemy(damage);setLog(`${player.skill}! You deal ${damage} damage.`);afterPlayerAction()}
function usePotion(){if(busy||player.potions<=0||player.currentHp>=player.hp)return;setActions(false);const heal=Math.min(38,player.hp-player.currentHp);player.currentHp+=heal;player.potions--;updatePlayer();setLog(`You drink a healing draught and recover ${heal} vitality.`);window.setTimeout(enemyTurn,700)}
function afterPlayerAction(){if(enemyHp<=0){window.setTimeout(victory,550)}else{window.setTimeout(enemyTurn,650)}}
function enemyTurn(){
  if(!player||player.currentHp<=0)return;
  const enemy=encounters[encounterIndex],damage=Math.max(3,enemy.attack+Math.floor(Math.random()*6)-(player.id==='guardian'?4:0));
  player.currentHp=Math.max(0,player.currentHp-damage);updatePlayer();
  if(player.currentHp<=0){setLog(`The ${enemy.name} overpowers you. Your legend ends here… for now.`);setActions(false);$('restart-button').textContent='TRY AGAIN';return}
  setLog(`The ${enemy.name} hits you for ${damage} damage.`);setActions(true);
}
function victory(){
  const enemy=encounters[encounterIndex];player.xp+=enemy.xp;player.gold+=enemy.gold;
  const oldLevel=player.level;while(player.xp>=player.level*40){player.xp-=player.level*40;player.level++;player.hp+=player.hpStat*2;player.mp+=player.mpStat*2;player.currentHp=Math.min(player.hp,player.currentHp+20);player.currentMp=Math.min(player.mp,player.currentMp+12)}
  updatePlayer();setActions(false);
  if(encounterIndex===encounters.length-1){setLog(`Victory! The mountain is silent. You earned ${enemy.xp} XP and ${enemy.gold} gold. The realm remembers your name.`);$('restart-button').textContent='PLAY AGAIN';$('journey-count').innerHTML='THE REALM IS SAVED <span>✦</span>';return}
  const leveled=player.level>oldLevel?` You reached level ${player.level}!`:'';
  setLog(`Victory! +${enemy.xp} XP · +${enemy.gold} gold.${leveled} The path leads onward…`);
  if(encounterIndex===0){player.potions++;setLog(`Victory! +${enemy.xp} XP · +${enemy.gold} gold. You found a potion.${leveled}`);updatePlayer()}
  $('attack-button').disabled=true;$('skill-button').disabled=true;$('potion-button').disabled=true;
  window.setTimeout(()=>{encounterIndex++;loadEncounter()},2100);
}
function returnToSelection(){
  $('game-screen').hidden=true;$('select-screen').hidden=false;player=null;selected=null;$('begin-button').disabled=true;
  document.querySelectorAll('.class-card').forEach(card=>{card.classList.remove('selected');card.setAttribute('aria-pressed','false')});
  window.scrollTo({top:0,behavior:'smooth'});
}
function restart(){if(selected)beginJourney()}
$('begin-button').addEventListener('click',beginJourney);$('retreat-button').addEventListener('click',returnToSelection);
$('attack-button').addEventListener('click',attack);$('skill-button').addEventListener('click',useSkill);$('potion-button').addEventListener('click',usePotion);$('restart-button').addEventListener('click',restart);
$('sound-toggle').addEventListener('click',()=>showToast('Ambient sound is coming soon.'));
function showToast(message){const toast=$('toast');toast.textContent=message;toast.classList.add('show');clearTimeout(logTimer);logTimer=window.setTimeout(()=>toast.classList.remove('show'),1900)}
document.addEventListener('keydown',event=>{
  if(!$('select-screen').hidden){if(['1','2','3'].includes(event.key))selectClass(classes[Number(event.key)-1].id);if(event.key==='Enter'&&selected)beginJourney();return}
  if(event.repeat||event.target.matches('input,textarea'))return;
  const key=event.key.toLowerCase();if(key==='a')attack();if(key==='q')useSkill();if(key==='p')usePotion();
});
renderClasses();
