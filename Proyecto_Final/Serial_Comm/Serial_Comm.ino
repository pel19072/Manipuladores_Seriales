#define RXD2 16
#define TXD2 17

char temp;

void setup() {
  Serial2.begin(9600, SERIAL_8N1, RXD2, TXD2);
  Serial.begin(9600);
  pinMode(5, OUTPUT);
}
void loop() {
  if (Serial2.available() > 0) {
    // Lectura serial, lee los 5 datos y almacena los 4 que no son un enter
    temp = Serial2.read();
    Serial.println(temp);
    //Serial2.write(temp);
    //delay(20);
  }
}
