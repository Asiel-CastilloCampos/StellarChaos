// Serial Reading/Writing with help of ChatGPT
// Physics simulation parts coded by ChatGPT

int numStars = 0;
boolean backgroundRed = false;
boolean showPath = false;

PVector[] positions = new PVector[3];
PVector[] velocities = new PVector[3];
float[] masses = {400, 400, 250};
float G = 2;
float starSize = 20;

color[] starColors = {color(0, 255, 255), color(255, 105, 180), color(255, 255, 0)};
ArrayList<PVector>[] trails = new ArrayList[3];
int trailLength = 130;
float trailThickness = 8;
ArrayList<PVector>[] paths = new ArrayList[3];

float orbitSize = 250;
float gravityReductionFactor = .5;
float minDistance = 200;

import processing.serial.*;

Serial myPort;

boolean buttonOnePushed = false;
boolean buttonTwoPushed = false;
boolean buttonThreePushed = false;

void setup() {
  size(2000, 900);
  noStroke();

  for (int i = 0; i < 3; i++) {
    positions[i] = new PVector(width / 2, height / 2);
    velocities[i] = new PVector(0, 0);
    trails[i] = new ArrayList<PVector>();
    paths[i] = new ArrayList<PVector>();
  }

  myPort = new Serial(this, Serial.list()[2], 9600);
  myPort.clear();
}

boolean collided = false;
int thirdSunTimer = 0;
boolean thirdSunActive = false;

void draw() {
  background(20);

  if (thirdSunActive && millis() - thirdSunTimer >= 10000) {
    G = 2;
    thirdSunActive = false;
  }

  for (int i = 0; i < numStars; i++) {
    trails[i].add(positions[i].copy());
    if (trails[i].size() > trailLength) {
      trails[i].remove(0);
    }

    if (showPath) {
      paths[i].add(positions[i].copy());
      if (paths[i].size() > 10000) {
        paths[i].remove(0);
      }

      for (int j = 1; j < paths[i].size(); j++) {
        stroke(starColors[i]);
        strokeWeight(2);
        line(paths[i].get(j - 1).x, paths[i].get(j - 1).y,
          paths[i].get(j).x, paths[i].get(j).y);
      }
    }

    for (int j = 0; j < trails[i].size(); j++) {
      float alpha = map(j, 0, 400, 0, 255);
      stroke(255, alpha);
      strokeWeight(trailThickness);
      if (j > 0) {
        line(trails[i].get(j - 1).x, trails[i].get(j - 1).y,
          trails[i].get(j).x, trails[i].get(j).y);
      }
    }
    noStroke();

    for (int j = 0; j < numStars; j++) {
      if (i != j && checkCollision(positions[i], positions[j], starSize / 2)) {
        collided = true;
        G = 100000;
        break;
      }
    }

    if (collided) {
      fill(255, 0, 0);
    } else {
      fill(starColors[i]);
    }

    ellipse(positions[i].x, positions[i].y, starSize, starSize);
    positions[i].add(velocities[i]);
  }

  for (int i = 0; i < numStars; i++) {
    for (int j = i + 1; j < numStars; j++) {
      PVector force = gravitationalForce(positions[i], positions[j], masses[i], masses[j]);
      velocities[i].add(force.copy().div(masses[i]));
      velocities[j].add(force.mult(-1).div(masses[j]));
    }
  }

  while (myPort.available() > 0) {
    String input = myPort.readStringUntil('\n');
    if (input != null) {
      input = input.trim();
      int buttonNumber = int(input);

      switch (buttonNumber) {
      case 1:
        if (numStars < 1) {
          numStars = 1;
          positions[0] = new PVector(width / 2 - orbitSize, height / 2);
          velocities[0] = new PVector(0, 0);
        }
        break;

      case 2:
        if (numStars < 2) {
          numStars = 2;
          positions[1] = new PVector(width / 2 + orbitSize, height / 2);
          float r = PVector.dist(positions[0], positions[1]);
          float v = 0.8;
          velocities[0] = new PVector(0, -v);
          velocities[1] = new PVector(0, v);
        }
        break;

      case 3:
        if (numStars < 3) {
          numStars = 3;
          positions[2] = new PVector(width / 2, height / 2 - 250);
          velocities[2] = new PVector(-0.3, -0.15);
          thirdSunTimer = millis();
          thirdSunActive = true;
        }
        break;

      default:
        println("Unknown button: " + buttonNumber);
        break;
      }
    }
  }
}

void keyPressed() {
  if (key == '1' && numStars == 0) {
    numStars = 1;
    positions[0] = new PVector(width / 2 - orbitSize, height / 2);
    velocities[0] = new PVector(0, 0);
  }
  if (key == '2' && numStars == 1) {
    numStars = 2;
    positions[1] = new PVector(width / 2 + orbitSize, height / 2);
    float r = PVector.dist(positions[0], positions[1]);
    float v = 0.8;
    velocities[0] = new PVector(0, -v);
    velocities[1] = new PVector(0, v);
  }
  if (key == '3' && numStars == 2) {
    numStars = 3;
    positions[2] = new PVector(width / 2, height / 2 - 250);
    velocities[2] = new PVector(-0.3, -0.15);
    thirdSunTimer = millis();
    thirdSunActive = true;
  } else if (key == '4') {
    G = 2;
    orbitSize = 250;
    gravityReductionFactor = 2;
    minDistance = 200;
    thirdSunActive = true;
    numStars = 0;
    thirdSunActive = false;
    gravityReductionFactor = 2;
  } else if (key == '5') {
    showPath = !showPath;
    if (!showPath) {
      for (int i = 0; i < 3; i++) {
        paths[i].clear();
      }
    }
  }
}

boolean checkCollision(PVector pos1, PVector pos2, float radius) {
  float distance = PVector.dist(pos1, pos2);
  return distance <= 2 * radius;
}

PVector gravitationalForce(PVector pos1, PVector pos2, float mass1, float mass2) {
  PVector direction = PVector.sub(pos2, pos1);
  float distance = constrain(direction.mag(), minDistance, 1000);

  if (distance < minDistance) {
    distance = minDistance;
  }

  direction.normalize();

  if (distance < 150) {
    float gravityFactor = map(distance, 0, 200, gravityReductionFactor, 1);
    direction.mult(gravityFactor);
  }

  float forceMagnitude = G * mass1 * mass2 / (distance * distance);
  return direction.mult(forceMagnitude);
}
