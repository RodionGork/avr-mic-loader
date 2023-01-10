# AVR Mic BootLoader and Programmer

This project allows to program AVR chips (AtMega328 etc, those used in Arduino)
using audio channel instead of cable or bluetooth. It works like this:

- User writes the code in web-editor (no need to install anything)
- On pressing "Compile" button code is compiled into hex form (ready firmware)
- Browser "beeps out" that prepared code through speaker
- AVR microcontroller catches the sound with directly attached microphone
- Microcontroller decodes transmission and writes resulting code into flash memory
- On normal start if Microcontroller doesn't detect audio transmission it executes that application code

### Motivation and Use-Case

The project is created for use in school classes to get rid of necessity of
installing any software (IDE etc) or connect any cables, kicking with virtual
COM-ports etc. My course assumes students creating small programs in assembly
to demonstrate and learn MCU features, so it is not intended to be handy for
large projects. On the other hand one may tune the project to be used with
specific speaker / microphone and significantly speed up the transmission if
necessary.

### Limitations

Transmission intentionally works on distance of 1-2 cm (that allows using
directly attached microphone and reduces 3rd party sound effects).

Transmission is not fast (about 20 bytes or 10 instructions per second) - this
is to allow greater reliability with wider range of general speakers, headphones
and microphones.

Code compilation for now is only supported from AVR Assembly (you still can
use any hex file compiled with any 3rd party tool).

Transmission is not extremely reliable, errors are detected with CRC and
one may need to make a couple of attempts to succeed.
