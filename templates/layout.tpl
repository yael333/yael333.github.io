<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
  <meta name="generator" content="cl-yag" />
  <title>%%Title%%</title>
  <link rel="stylesheet" type="text/css" href="./static/css/style.css" media="screen" />
  <link rel="alternate" type="application/rss+xml" title="%%Title%% RSS Feed" href="./rss.xml" />
  <link rel="alternate" type="application/rss+xml" title="%%Title%% RSS Feed Gopher" href="./rss-gopher.xml" />
  <!--    <link rel="alternate" type="application/atom+xml" title="%%Title%% Atom Feed" href="atom.xml" /> -->
  <link rel="icon" type="image/x-icon" href="static/img/favicon.ico" />
</head>

<body>
  <div id="wrapper">
    <main>
      <div class="list">
        <div class="box square">
          <a href=".">
            meowww<br>
            (welcome)<br>
            <b>&gt;_&lt;</b> <br>
            have fun
          </a>
        </div>
        <div class="box sel">
          <a href=".">home&nbsp; ⌂
            <span class="arrow">&gt;</span></a>
        </div>
        <div class="box ">
          <a href="my_music">music ♫
            <span class="arrow">&gt;</span></a>
        </div>
        <div class="box ">
          <a href="meowindex">meows ~
            <span class="arrow">&gt;</span></a>
        </div>

        <div class="box ">
          <a href="cool">cool &nbsp;▼ stuff ▲
            <span class="arrow">&gt;</span></a>
        </div>
        <div class="box ">
          <a href="meta">meta •○
            <span class="arrow">&gt;</span></a>
        </div>
        <div class="notbox">
          <a href="/rss.xml"><img src="img/rss.gif"></a>
        </div>

        <img class="sleepyoneko" src="img/sleepyoneko.gif">
        <div class="statusbox">
          <div>
            current status: <b class="r">
              anxious+</b>
          </div>
          <div>
            present day/time: <b class="r" id="autoclock">Tue 21:19</b>
          </div>
          <div>
            site last updated: <b class="r fm">
              7月21日</b>
          </div>
          <div>
            uptime:
            <b class="r">
              18 days</b>
          </div>
          <div>
            meow:
            <b class="r" id="mreoww">mreoww</b>
          </div>
        </div>


        <div class="volumebox">
          <div>volume</div>
          <input type="range" id="mp-volume" oninput="on_global_volume_update()" min="10" max="100" value="90">
          <div class="nudge">♪ <div class="r">♪♪♪</div>
          </div>
        </div>

        <script>
          // automatic clock in sidebar
          // php should give something reasonable to start off with
          function getTime() {
            const currentTime = new Date(new Date().toLocaleString("en-US", { timeZone: "Canada/Eastern" }));

            const weekday = currentTime.toLocaleDateString('en-US', { weekday: 'short' }).slice(0, 3);
            const time = currentTime.toLocaleTimeString('en-US', { hour12: false, hour: '2-digit', minute: '2-digit' }).slice(0, 5);
            return weekday + ' ' + time.replace("24:", "00:"); // CHROME !!!!! :<
          }

          document.getElementById('autoclock').textContent = getTime();

          setInterval(function () {
            document.getElementById('autoclock').textContent = getTime();
          }, 30000);
        </script>

      </div>

      <div class="main">
        %%Body%%
      </div>

      <div class="bottom">
        <span>© 2023 natu.moe</span>
        
        <img src="img/miku.gif" width="88" height="32">
        <img src="img/e2.gif" width="88" height="32">
        <img src="img/best800x600.gif" width="88" height="32">
        <a href="https://dimden.dev/"><img src="img/dimden.gif?3" width="88" height="32"></a>
        <a href="http://stormypetrel.sakura.ne.jp/daturyoku.htm"><img class="wide" src="img/daturyok.gif" width="160" height="32" border="0"></a>
        </div>

    </main>

  </div><!-- #wrapper -->
</body>

</html>