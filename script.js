terminal = document.querySelector("#terminal")
page = document.querySelector("#page")
text = 
	[
	["hi", 500],
	["swag", 1000],
	["dab", 500],
	]
function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

console.log(terminal.children)

async function main()
{
	terminal.style.display = "block"
	page.style.display = "none"
	for (let line in text)
	{
		terminal.children[0].innerHTML += text[line][0] + "<br>"
		await sleep(text[line][1])
	}
	terminal.style.display = "none"
	page.style.display = "block"	
}

main()