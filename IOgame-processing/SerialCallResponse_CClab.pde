/** 
 * Serial Call-Response 
 * by Tom Igoe. 
 * 
 * Sends a byte out the serial port, and reads 3 bytes in. 
 * Sets foregound color, xpos, and ypos of a circle onstage
 * using the values returned from the serial port. 
 * Thanks to Daniel Shiffman  and Greg Shakar for the improvements.
 * 
 * Note: This sketch assumes that the device on the other end of the serial
 * port is going to send a single byte of value 65 (ASCII A) on startup.
 * The sketch waits for that byte, then sends an ASCII A whenever
 * it wants more data. 
 */
 

import processing.serial.*;

int bgcolor;			 // Background color
int red;			     // Fill colors
int green;
int blue;
Serial myPort;                       // The serial port
int[] serialInArray = new int[4];    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive
int xpos, ypos, radius;             // Starting position of the ball
boolean firstContact = false;        // Whether we've heard from the microcontroller
boolean win = false;
int light;

int speed;
int size;
int xposDot, yposDot;
int rDot,gDot,bDot;

void setup() {
  size(1300, 1300);  // Stage size
  noStroke();      // No border on the next thing drawn

  red = int(random(255));
  green = int(random(255));
  blue = int(random(255));
  
  rDot = int(random(255));
  gDot = int(random(255));
  bDot = int(random(255));
  // Set the starting position of the ball (middle of the stage)
  xpos = width/2;
  ypos = height/2;
  radius = 30;
  
  size = int(random(20, 50));
  speed = int(random(1, 20));
  xposDot = 0;
  yposDot = int(random(0, width/2));
  
  // Print a list of the serial ports, for debugging purposes:
  printArray(Serial.list());

  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 9600);
}

void draw() {
  background(bgcolor);
  fill(red, green, blue);
  // Draw the shape
  ellipse(xpos, ypos, radius, radius);
  
  fill(rDot, gDot, bDot);
  ellipse(xposDot, yposDot, size, size);
  
  if((dist(xpos, ypos, xposDot, yposDot) < radius + size)&& (serialInArray[2] == 255)){
      win = true;
  }else {
    win = false;
  }
  
  xposDot = xposDot + speed;
  
  if(xposDot >= width){
    xposDot = 0;
    yposDot = int(random(0, width/2));
    speed = int(random(1,20));
    rDot = int(random(255));
    gDot = int(random(255));
    bDot = int(random(255));
  }
  
  //delay(100);
  
}

void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  int inByte = myPort.read();
  // if this is the first byte received, and it's an A,
  // clear the serial buffer and note that you've
  // had first contact from the microcontroller. 
  // Otherwise, add the incoming byte to the array:
  if (firstContact == false) {
    if (inByte == 'A') { 
      myPort.clear();          // clear the serial port buffer
      firstContact = true;     // you've had first contact from the microcontroller
      myPort.write('A');       // ask for more
    } 
  } 
  else {
    // Add the latest byte from the serial port to array:
    serialInArray[serialCount] = inByte;
    serialCount++;

    // If we have 3 bytes:
    if (serialCount > 3 ) {
      radius = int(map(serialInArray[0], 0, 255, 20, 500));
      ypos = height - int(map(serialInArray[1], 70, 250, 20, 800));
      red = serialInArray[2];
      light = serialInArray[3];

      // print the values (for debugging purposes only):
      println(radius + "\t" + ypos + "\t" + red + "\t" + light + "\t" + win);
      //println(serialInArray[0] + "\t" + serialInArray[1] + "\t" + serialInArray[2]);

      // Send a capital A to request new sensor readings:
      if(win == true){
        myPort.write('B');       // ask for more
      }else{
        myPort.write('A');       // ask for more
      }
      // Reset serialCount:
      serialCount = 0;
    }
  }
}