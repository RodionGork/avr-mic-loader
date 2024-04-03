void setup() {
  pinMode(2, INPUT);
  pinMode(5, OUTPUT);
  Serial.begin(115200);
}

void loop() {
  static byte fronts = 0;
  static byte bits;
  static byte prev;
  static byte cur = 1;
  static long t, tp = 0;
  static byte t0, t1;
  byte v = analogRead(A0)>>2;
  prev = cur;
  cur = (v & 128);
  t = millis();
  long dt = t - tp;
  if (dt > 200 && fronts) goto reset;
  if (cur == prev) return;
  tp = t;
  byte d = (byte) dt;
  if (++fronts < 4) {
    switch(fronts) {
      case 1:
        if (cur) goto reset;
        return;
      case 2:
        t0 = d*3/2;
        //Serial.print("x");Serial.println(d);
        return;
      case 3:
        t1 = d*3/2;
        //Serial.print("y");Serial.println(d);
        return;
    }
  } else {
    byte b = (fronts % 2) ? (d>t1?1:0) : (d>t0?1:0);
    //Serial.print(d);Serial.write(':');Serial.println(b);
    bits = (bits<<1) | b;
    if (fronts < 11) return;
    Serial.write(bits);
    fronts = 1;
    return;
  }
  reset:
  fronts = 0;
}


void loop_check_shape() {
  static int on = 0;
  static byte buf[500];
  static byte avg = 32;
  byte v = analogRead(A0)>>4;
  if (!on) {
    if (v > 32) return;
  }
  
  Serial.println(v);
  on++;
  if (on == sizeof(buf)) on = 0;
  buf[on++] = v;
  if (on == sizeof(buf)) {
    for (on = 0; on < sizeof(buf); on++)
      Serial.println(buf[on]);
    on = 0;
  }
  delay(2);
}
