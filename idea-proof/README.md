# Proof Of Concept

Use Arduino based on AtMega328 or something similar. Upload the `receiver`
firmware. Attach typical "electret" microphone between `GND` and `A3`. Attach
`10k` resistor between `A3` and `VCC`.

Open the `sound.html` file in your browser (or ideally, run `python3 -m http.server`
from this folder and open the file in the browser of your mobile phone.

Type in some text in the input field on the page. Bring the phone's speaker
close to microphone (about 1-2 cm distance), make sure it is on max volume.

Open `Serial Monitor` in Arduino IDE.

Press the `Beep` button. You should see your text appearing in the serial console.

Debug mode is enabled by connecting `pin 9` to `GND` (in this case serial
console shows reception of every bit, ADC levels etc).

### Receiver-air

This setup requires few more components (transistor, capacitor and resistor.
Scheme is yet to be added. Explanation too.