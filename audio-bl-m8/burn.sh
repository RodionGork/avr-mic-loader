~/utils/avrdude/avrdude \
  -C/home/rodion/utils/avrdude/avrdude.conf \
  -pm8 -P/dev/ttyUSB0 -b19200 -cavrisp \
  -e -U flash:w:audio-bl.hex
