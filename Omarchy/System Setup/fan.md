# CPU Smart Fan (quiet curve)

Beelink SER9, AMI setup. **Advanced → CPU Smart Fan Mode → Automatic.**

Stock spins the fan through normal idle. This curve keeps it off until the CPU is actually working, and starts it at the quietest duty the BIOS allows. Noise on this machine dropped a lot.

| Setting | Stock (approx.) | This machine | Why |
| --- | --- | --- | --- |
| Fan OFF temperature | 30–35 °C | 45 °C | Fan stays off for normal idle |
| Fan ON temperature | 35–40 °C | 50 °C | Starts only when load actually builds |
| Full PWM temperature | 90 °C | 90 °C | Unchanged; AMD is fine until ~90–95 |
| Start PWM | ~80 | 65 | Beelink minimum; quieter spin-up |
| Slope PWM | 1 | 1 | Slow ramp; raise it only if the fan lags behind the temperature |

Power limit stays **Balanced (~54 W)**. Keep Balanced when quiet is the goal. Performance is 65 W, runs hotter, and the fan follows.

A [CMOS reset](known-issues.md#intel-ax200-wi-fi-gone-until-cmos-reset) restores the stock curve. Enter these values again after a clear.
