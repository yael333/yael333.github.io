terminal = document.querySelector("#terminal")
page = document.querySelector("#page")
audio = document.getElementById("audio");
text = 
	[
	["hi", 500],
	["swag", 1000],
	["dab", 3000],
	]
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function main(event)
{
	document.removeEventListener('mousedown', main, {once: true});
	document.removeEventListener('keypress', main, {once: true});
	document.removeEventListener('touchstart', main, {once: true});
	terminal.children[1].remove()
	audio.play();

	for (let line in text)
	{
		terminal.children[0].innerHTML += text[line][0] + "<br>"
		await sleep(text[line][1])
	}
	terminal.style.display = "none"
	page.style.display = "block"
	await sleep(250)
	volume = 0.5
	while (audio.volume > 0.01)
	{
		await sleep(50)
		audio.volume -= 0.01
	}
	audio.pause()
}

function listenEvents()
{
	document.addEventListener('mousedown', main, {once: true});
	document.addEventListener('keypress', main, {once: true});
	document.addEventListener('touchstart', main, {once: true});
}

window.onload = listenEvents
terminal.style.display = "block"
page.style.display = "none"