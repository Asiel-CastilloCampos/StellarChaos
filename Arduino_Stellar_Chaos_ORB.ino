#include <Adafruit_NeoPixel.h>

int pin = 8;
int numPixels = 16;
Adafruit_NeoPixel strip = Adafruit_NeoPixel(numPixels, pin);

int brightness = 5;
bool fadeIn = true;

void setup() {
  strip.begin();
  strip.show();
}

void loop() {
  for (int i = 0; i < numPixels; i++) {
    strip.setPixelColor(i, strip.Color(brightness / 4, brightness / 4, 0));
  }

  if (random(0, 100) < 15) {
    int randomPixel = random(0, numPixels);
    strip.setPixelColor(randomPixel, strip.Color(255, 255, 255));
  }

  strip.show();

  if (fadeIn) {
    brightness++;
    if (brightness >= 100) fadeIn = false;
  } else {
    brightness--;
    if (brightness <= 0) fadeIn = true;
  }

  delay(5);
}
