int buttonOne = 4;
int buttonTwo = 3;
int buttonThree = 2;

void setup() {
  pinMode(buttonOne, INPUT);
  pinMode(buttonTwo, INPUT);
  pinMode(buttonThree, INPUT);

  Serial.begin(9600);
}

// Serial Writing/Reading with help of ChatGPT
void loop() {
  if (digitalRead(buttonOne) == LOW) {
    Serial.println(1);
    delay(200);
  } else if (digitalRead(buttonTwo) == LOW) {
    Serial.println(2);
    delay(200);
  } else if (digitalRead(buttonThree) == LOW) {
    Serial.println(3);
    delay(200);
  }
}
