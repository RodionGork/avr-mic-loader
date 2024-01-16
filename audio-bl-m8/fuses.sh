~/utils/avrdude/avrdude \
  -C/home/rodion/utils/avrdude/avrdude.conf \
  -pm8 -P/dev/ttyUSB0 -b19200 -cavrisp \
  -U hfuse:w:0xD8:m
#  -U hfuse:r:test.hex:i