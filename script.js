// body = document.body
// terminal = document.querySelector("#terminal")
// page = document.querySelector("#page")
// audio = document.getElementById("audio");
// text = 
// 	[
// 	["konataOS boot ok!", 750],
// 	["...", 200],
// 	["/home/konata/mypage", 500],
// 	["page loading...", 800],
// 	["initializing engine...", 1200],
// 	["render mode: software", 600],
// 	["sound card compatible...", 500],
// 	["checking gay levels...", 1500],
// 	["gay levels ok!", 500],
// 	["checking system...", 1000],
// 	["minimum specs ok!", 500],
// 	["--------------------------------", 500],

// 	]

// function sleep(ms) {
//   return new Promise(resolve => setTimeout(resolve, ms));
// }

// function listenEvents()
// {
// 	document.addEventListener('mousedown', main, {once: true});
// 	document.addEventListener('keypress', main, {once: true});
// 	document.addEventListener('touchstart', main, {once: true});
// }

// async function main(event)
// {
// 	document.removeEventListener('mousedown', main, {once: true});
// 	document.removeEventListener('keypress', main, {once: true});
// 	document.removeEventListener('touchstart', main, {once: true});
// 	terminal.children[1].remove()
// 	audio.play();

// 	for (let line in text)
// 	{
// 		terminal.children[0].innerHTML += text[line][0] + "<br>"
// 		await sleep(text[line][1])
// 	}
// 	terminal.style.display = "none"
// 	page.style.display = "block"
// 	await sleep(250)
// 	volume = 0.5
// 	while (audio.volume > 0.01)
// 	{
// 		await sleep(50)
// 		audio.volume -= 0.01
// 	}
// 	audio.pause()
// }

// window.onload = listenEvents
// terminal.style.display = "block"
// page.style.display = "none"