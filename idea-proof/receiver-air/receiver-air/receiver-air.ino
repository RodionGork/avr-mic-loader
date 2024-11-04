#define INPUT_PIN 3
#define DEBUG 1

long n = 0;
long c = 0;
int r = 0;
int b;
byte bc = 0;

void setup() {
  Serial.begin(115200);
}

void loop() {
  if (digitalRead(INPUT_PIN) == LOW) {
    if (r > 0) {
      byte v = (1000 - r < 50) ? 0x80 : 0;
      #if DEBUG
      Serial.write(v ? '$' : '-');
      #else
      if (bc > 0) {
        b = ((b >> 1) | v);
        if (--bc == 0) {
          Serial.write(b);
        }
      } else if (!v) {
        bc = 8;
      }
      #endif
    }
    for (int i = 0; i < 100; i++)
      digitalRead(3);
    r = 1000;
  } else {
    if (r > 0) {
      r--;
      #if DEBUG
      if (!r)
        Serial.println();
      #endif
    }
  }
}
