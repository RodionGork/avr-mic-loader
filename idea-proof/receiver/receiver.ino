#define BTN 9
#define DBSZ 64

unsigned int avg;
unsigned int avgdisp;

byte dispbuf[DBSZ];
byte dispidx;
byte ticks;

bool fallgap;

byte bits;
byte par;
int bitcnt;

void setup() {
  Serial.begin(115200);
  pinMode(BTN, INPUT_PULLUP);
  ADMUX = 0x43;
  ADCSRA = 0xE6;
  avg = 512 << 4;
  avgdisp = 0;
  for (dispidx = 0; dispidx < DBSZ; dispidx++) {
    dispbuf[dispidx] = 0;
  }
  ticks = 0;
  fallgap = false;
  bitcnt = 0;
}

void loop() {
  if ((ADCSRA & 0x10) == 0) {
    return;
  }
  int x = ADCL;
  x |= (ADCH << 8);
  ADCSRA |= 0x10;
  if (ticks < 255) {
    ticks++;
  } else {
    bitcnt = 0;
  }
  int d = x - (avg >> 4);
  avg += d;
  if (d < 0) {
    d = -d;
  }
  avgdisp += d - (avgdisp >> 4);
  byte newdisp = (avgdisp >> 4);
  byte previdx = dispidx + 15;
  if (previdx >= DBSZ) {
      previdx -= DBSZ;
  }
  byte prevdisp = dispbuf[previdx];
  dispbuf[--dispidx] = newdisp;
  if (dispidx == 0) {
    dispidx = DBSZ;
  }
  if (!fallgap) {
    if (prevdisp > newdisp && prevdisp > 10 && (prevdisp - newdisp) >= prevdisp >> 2) {
      fallgap = true;
      int delta = ticks;
      if (delta < 45 || delta > 170) {
        bitcnt = 0;
      }
      ticks = 0;
      if (digitalRead(BTN) == LOW) {
        Serial.print(delta);
        Serial.print(' ');
        Serial.print(bitcnt);
        Serial.print(' ');
        Serial.print(prevdisp);
        Serial.print(' ');
        Serial.print(newdisp);
        Serial.print(' ');
      }
      byte bitval = (delta > 100) ? 0 : 0x80;
      if (bitcnt == 0) {
        if (bitval == 0) {
          bitcnt = 10;
          par = 0;
        }
      } else {
        bitcnt--;
        if (bitcnt > 1) {
          bits = (bits >> 1) | bitval;
          par ^= bitval;
        } else if (bitcnt == 1) {
          if (bitval != par) {
            Serial.print(".pe.");
            bitcnt = 0;
          }
        } else {
          if (bitval == 0) {
            Serial.print(".fe.");
          } else {
            Serial.write(bits);
          }
        }
      }
      if (digitalRead(BTN) == LOW) {
        Serial.println();
      }
    }
    return;
  } else {
    if (ticks >= 40) {
      fallgap = false;
    }
  }
}
