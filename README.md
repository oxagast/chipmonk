# chipmonk
## NUT (Network UPS Tools) Visual Power Dialogs

<a href="https://oxasploits.com/posts/chipmonk-nut-network-ups-tools-ups-power-outage-backup-script/">The oxasploits writeup</a>

Chipmonk works with NUT (Network UPS Tools) to monitor UPS events.

There are script blocks where users can add their own script calls from Chipmonk to
do things like save data around the system before the UPS battery is drained.

Chipmonk works by starting and monitoring the `upslog` process.  One started instance
of upslog will automatically log to `/var/log/nut/ups.log`, the other is monitored for
internal trigger events on state changes (like power outage, or low battery).

![Image](https://raw.githubusercontent.com/oxagast/chipmonk/main/demo.png "Demo")

<iframe width="1269" height="714" src="https://www.youtube.com/embed/2XpJRGQN2Kk" title="Chipmonk UPS PoC" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
