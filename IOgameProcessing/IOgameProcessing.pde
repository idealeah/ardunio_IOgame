/** 
  An Arduino/Processing serial communication game based on the arduino example sketch
  
  Created September 2019 by Leah Willemin 

  ___________________________________________
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

int hue;			     //HSB fill colors for main ball
int saturation = 100;
int brightness;
int xpos, ypos, radius;    //Starting position of the ball

int speed;  //Speed of the moving dot
int size;    //Size of the moving dot
int xposDot, yposDot;  //Location of the moving dot

//HSB color of the moving dot:
int hDot;
int sDot = 100;
int bDot;  
boolean dotCatch = false;

int points = 0;   // Game points
boolean win = false; //Game winning 
int valueSent; //the value Arduino receives and sends back
int button; //button value

int bgHue;  //background hue
 
Serial myPort;                       // The serial port
int[] serialInArray = new int[4];    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive
boolean firstContact = false;        // Whether we've heard from the microcontroller

int winRadius = 0;

void setup() {
  size(1300, 1300);  // Stage size
  colorMode(HSB, 360, 100, 100);
  noStroke();      // No border on the next thing drawn

  //set hue and brightness of background and main dot
  bgHue = int(random(360));
  hue = int(random(360));
  brightness = int(random(50, 100));
  
  //set hue and brightness of moving dots
  hDot = int(random(360));
  bDot = int(random(50, 100));
  
  // Set the starting position of the ball (middle of the stage)
  xpos = width/2;
  ypos = height/2;
  radius = 30;
  
  //Randomize the size, speed, and location of the moving dot
  size = int(random(20, 60));
  speed = int(random(1, 20));
  xposDot = 0;
  yposDot = int(random(height));
  
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
  background(bgHue, 100, 80);
  //if you haven't won the game
  if (win == false){
    int ballHue = hue-button/2;
    fill(ballHue, saturation, brightness);
    // Draw the main ball
    ellipse(xpos, ypos, radius, radius);
    
    // Draw the moving dot
    fill(hDot, sDot, bDot);
    ellipse(xposDot, yposDot, size, size);
    
    //Test location of the ball and the moving dot: if they meet and the button is pressed, add a point
    if((dist(xpos, ypos, xposDot, yposDot) < (radius + size - 20)) && (serialInArray[2] == 255)){
      if (dotCatch == false){ 
        if (hDot >= 300 || hDot <= 30){
          if(points > 0){
            points -= 1;    //if it's a red dot, lose points
          }
        }else{
          if(points < 5){
            points += 1;    //if it's not a red dot, gain points
          }
        }
        dotCatch = true;
      }
    }
  }else if(win == true){      // Draw win screen
    fill(hue, saturation, brightness);
    // Draw the main ball increasing in size
    int increase = 5;
    ellipse(xpos, ypos, winRadius, winRadius);
    if (winRadius < height*2){
      winRadius = winRadius + increase;
    }if (winRadius >= height*2){
      fill(0);
      textSize(50);
      text("(press button to restart)", width/2 - 280, height/2);
      if (button == 255){    //reset everything when button is pressed
        win = false;
        points= 0;
        winRadius = 0;
        bgHue = int(random(360));
        xposDot = 0;
        yposDot = int(random(height));
      }
    }
  }
  
  // Test for winning
  if (points == 5){
     win = true;
  }
  else {
     win = false;
  }
  
  // Increment dot location according to speed
  xposDot = xposDot + speed;
  
  // Test dot x-value: Has it reached the canvas bounds?
  if(xposDot >= width){
    // Set dot X-value back to 0
    xposDot = 0;
    // Randomize dot size, speed, y-value, and color
    yposDot = int(random(width));
    speed = int(random(1,20));
    size = int(random(20, 60));
    hDot = int(random(360));
    bDot = int(random(50, 100));
    dotCatch = false;
  }
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
      //map and set dot values from sensor input
      radius = int(map(serialInArray[0], 0, 255, 20, 500));
      if(win == false){
        ypos = height - int(map(serialInArray[1], 0, 255, 20, 1200));
      }
      button = serialInArray[2];
      valueSent = serialInArray[3];

      // print the values (for debugging purposes only):
      println(serialInArray[0] + "\t" + serialInArray[1] + "\t" + "button=" + button + "\t" + valueSent + "\t" + "points=" + points + "\t" + "win?="
      + win);
      //println(serialInArray[0] + "\t" + serialInArray[1] + "\t" + serialInArray[2]);

      // Send a capital A to request new sensor readings:
      //if(win == true){
      //  myPort.write(5);       // ask for more
      //}else{
        myPort.write(points);       // ask for more
      //}
      // Reset serialCount:
      serialCount = 0;
    }
  }
}