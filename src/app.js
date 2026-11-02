const cards = [...document.querySelectorAll('.class-card')]
const selectedName = document.querySelector('#selected-class')
let selectedIndex = Math.max(0, cards.findIndex((card) => card.classList.contains('selected')))

function selectClass(index) {
  if (!cards.length) return
  selectedIndex = (index + cards.length) % cards.length
  cards.forEach((card, cardIndex) => {
    const selected = cardIndex === selectedIndex
    card.classList.toggle('selected', selected)
    card.setAttribute('aria-pressed', String(selected))
  })
  if (selectedName) selectedName.textContent = cards[selectedIndex].dataset.class || cards[selectedIndex].querySelector('.class-name')?.textContent || ''
}

cards.forEach((card, index) => card.addEventListener('click', () => selectClass(index)))
document.querySelector('.class-prev')?.addEventListener('click', () => selectClass(selectedIndex - 1))
document.querySelector('.class-next')?.addEventListener('click', () => selectClass(selectedIndex + 1))
selectClass(selectedIndex)
