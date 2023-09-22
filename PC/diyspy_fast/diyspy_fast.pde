/*
DIY-Spy grapher

Cheap and dirty hack to demonstrate the spectrum analyzer. Data comes in on the serial port (or USB faked variant thereof)
as 256-byte blocks of data corresponding to the 256 channels swept. The 0th channel's data is indicated by a '1' in the 
least significant bit; all others have this bit set to 0.

IMPORTANT: Change the value of 'comPort' below to reflect the port the device is attached to.

20090817 / tgipson
*/

import processing.serial.*;

// -------------------------------
final String comPort = "COM8";        // CHANGE to correct serial port, if there is more than one. See the list that is printed when the program starts.

final int nPoints = 256;        // Number of datapoints to display on the chart

//final int ChartX = 1024;       // Dimensions of chart window
//final int ChartY = 512;              // has to be given as literal to size() 
final int heightPadding = 45; // space set aside for axis labeling

final int scaler = 4; // amount to scale the data vertically

final int rssi_offset = 72;  // CC2500's RSSI baseline offset in dBm.

//int LegendX = 700;      // Position of the chart legend on screen
//int LegendY = 60;

final float freqMin = 2.400; // base frequency (ch. 0) in GHz
final float freqStep = 0.000405; // channel spacing
final float axisStep = .005; // axis display spacing

final float freqMax = freqMin + (256*freqStep);  //2.50368;


// --------------------------------



Serial myPort;
PFont myFont;




int[] datapoints = new int[nPoints];
int[] maxes = new int[nPoints];
int[][] averages = new int[nPoints][2];

int chan=0;
boolean draw_sync = false;
boolean  primed = false;
int rssi;


void setup()
{
  rectMode(CORNERS);
  ellipseMode(CENTER);
  size(1024, 512);
  println (datapoints.length);

  println(Serial.list());
  myPort = new Serial(this, comPort /*Serial.list()[0]*/, 9600, 'N', 8, 1);
  println(myPort.available());

  myFont = loadFont("ArialMT-48.vlw");
  textFont(myFont, 60);
  textSize(heightPadding/3);
}

void draw()
{
  if (draw_sync)
  {
    draw_sync= false;
    background(0);
    graph();
  }
}



void graph()
{
    pushStyle();

    stroke(255,255,255);
    fill(255,255,255);

  for (float i = freqMin; i < freqMax; i=i+axisStep)
  {
    pushMatrix();
    translate( map(i, freqMin, freqMax, 0, width), height-heightPadding); // (width*(i/freqMax))
    rotate(radians(90));
    text(i , 0, 0);
    popMatrix();    
  }

    popStyle();

  for (int i=0; i<datapoints.length; i++)
  {

    stroke(100,0,0);
    fill(100, 0, 0);
    rect(((width/nPoints)*i),     height-heightPadding,     ((width/nPoints)*(i+1)),   height - heightPadding - (height/nPoints)*maxes[i]*scaler);                             /**ChartX/datapoints.length*//**ChartX/datapoints.length*/
    // dashes only
    //rect(((width/nPoints)*i),     ( height - heightPadding - (height/nPoints)*maxes[i]*scaler)+1,     ((width/nPoints)*(i+1)),   (height - heightPadding - (height/nPoints)*maxes[i]*scaler));  
 /*
    if (averages[i][1] > 0)
    {
      stroke(0,0,255);
      fill(0, 0, 255);
      rect(((width/nPoints)*i),   height-heightPadding,     ((width/nPoints)*(i+1)),   height - heightPadding - (height/nPoints)*(averages[i][0] / averages[i][1])*scaler);
    }
  */  
    
    stroke(0,255,0,0);  // eliminate the stroke by alpha 0 since the next bars stroke overlaps otherwise
    fill(0, 255, 0, 155);
    rect(((width/nPoints)*i),     height-heightPadding,     ((width/nPoints)*(i+1)),   height - heightPadding - (height/nPoints)*datapoints[i]*scaler);           /**ChartX/datapoints.length*//**ChartX/datapoints.length*/
  }

}

void serialEvent(Serial myPort)
{
  rssi = myPort.readChar();
  if ((rssi & 0x01) == 0x01) // '1' in lowest bit indicates start of frame (0th channel data)
  {
    chan=0;
    primed = true;
  }
  else
  {
    chan++;
  }

  if (primed ) // have received the ch0 flag
  {
      // convert rssi byte to real output in dBm. After killing off LSB, output is in signed (dBm*2 + offset).
      rssi = rssi & 0xfe;
      rssi = ss(rssi);
     
      rssi = rssi/2 - rssi_offset;
      if (rssi >50)
      {
         print("chan = " + chan + " rssi = " + rssi );
         println(" Freq = " + (freqMin +(chan*freqStep)));
      }
   
      datapoints[chan] = rssi;
      averages[chan][0] = averages[chan][0] + rssi;
      averages[chan][1] = averages[chan][1] + 1;
      
      if (rssi > maxes[chan])
      {
        maxes[chan] = rssi;
      }
      
      if (chan ==0 )
        draw_sync = true;

  }
}


int ss(int unsigned)
{
  if (unsigned < 128)
  {
    unsigned = (256 - unsigned);
  }
  return unsigned; // now signed...
}
