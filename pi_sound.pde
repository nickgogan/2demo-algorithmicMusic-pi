//By: Nick Gogan
//05/05/14
//Purpose: Algoritmically generate music using the digits of pi as the main basis for the piece 
import java.util.*;
import arb.soundcipher.*;

SoundCipher sc = new SoundCipher(this);//, new SoundCipher(this)}; //1 cipher per scale/mode
SCScore piano = new SCScore();
//SCScore violin = new SCScore();

String[] digits = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};
float[] notes, pitches, dynam, dur, arti, pans, container; //mode
float[] chordpitches = new float[3]; //automatically initialized to 0.0's
float[] durations = {0.6, 0.6, 0.6, 0.6}; //bpm's {0.20, 0.25, 0.50, 0.60}
float[][] modes = {sc.MAJOR_PENTATONIC, sc.MINOR_PENTATONIC, sc.PENTATONIC, sc.MAJOR}; //NOTE: all sets are for scales/modes with C as root pitch. 

float chordur, chorddynam;//Chord parameters

float instruments = sc.PIANO;//, sc[0].VIOLIN}; //[0,127], with 0 = PIANO on the JavaSound synthesizer
float instr;
double ch = 0.0; //Default value, [0,15]
double startBeat = 1.0; //Specifies when the note will play after code execution (measured in beats)

int startdigit = 5001;
int finaldigit = 10001;  
int cycle = 0;
//int notes = finaldigit - startdigit;
int uni = 0; //(int)random(0,3); 
int tempo = 60; //round(0.5+random(-1,1)*0.2); //Try the default 128 bpm if it doesn't seem to work 
int keyOffset = 0; //Can use this value to generate scales/modes that're not in C 

void setup() {
  //frameRate(1); //How does this help? 
  String[] data = loadStrings("pidat.txt");
  int totalnotes = finaldigit - startdigit; //find out the number of single digits/notes in the given range
  int counter = 0;
  pitches = new float[totalnotes]; //Initialize the main container
  //Generates the array of floating point values for the pitches from the data 
  for(int i = 0; i < totalnotes; i++) {
    for(int j = 0; j < digits.length; j++) {
      //println(container[i], container[i+startdigit],digits[j]);
      if(data[i + startdigit].equals(digits[j]) == true) { //Proper way of comparing 2 strings here
         pitches[counter] = (float) j; //Here, the index j has the same magnitude as its corresponding element, but is an int (change it manually to a float)
         counter++; //Bonus: confirms number of notes in the pitches container
      }
    }
  }
 //printArray(pitches);
 //println(pitches.length);
  Init(); //Called to instantiate and initialize the remaining parameter arrays based off of the pitches one just found
  Map();
  makeMusic();  
}

void draw() { }

void Init() {
//Instantiate and initialize the other parameter arrays to 0.0's
  dynam = new float[pitches.length];
  dur = new float[pitches.length];
  pans = new float[pitches.length];
  arti = new float[pitches.length];
  
  container = new float[pitches.length];
} 

void Map() {
  for(int i=0; i < pitches.length; i++) {
    pitches[i] = map(pitches[i], 0,9, 60,110); //Mapping from [0,9] (decimal system) to [0,127] pitch system 
    dynam[i] = cos(i*PI*2*0.25)*30 + random(0,20) + 90;
    dur[i] = durations[uni]; //Initial note duration 
    arti[i] = 0.4; //Default value; [0.2, 0.8] = [stacatto, legato] 
    pans[i] = 64; //Default value, corresponding to the center position, [0,127]
    instr = instruments; //Piano
    //println(instruments[0]);
    chordur = 1.5*dur[i];
    chorddynam= sin(i*PI/2*0.75)*30 + random(0, 20) + 90;
  }
}
float pPerlin = 37.4;
float tPerlin = 12.75;
int modeQuantize(float[] pitches, float[][] modes, int keyOffset, int counter_) {
  int counter = counter_;
  counter = 0;
 // println(counter);
  for(int i=0; i < pitches.length; i++) { //Loop over all pitches 
    pitches[i] = (int)(pitches[i]); //Recast pitches from floats to ints
    //println(i, uni);
    for(int j=0; j < modes[uni].length ; j++) { //Check through all of the rounded pitches to see which match those of the current mode. Those that do are then stored in the notes container, indexed by counter
          if( (pitches[i] - keyOffset)%12 == modes[uni][j] ) {
           // container[counter] = modes[uni][j];
           //violin.addNote(counter*0.5, ch, instr, modes[uni][j], dynam[counter], dur[counter], arti[counter], pans[counter] );
            piano.addNote(counter*0.5, ch, instr, modes[uni][j], dynam[counter], dur[counter], arti[counter], pans[counter] );
            //piano.addNote((double) noise(pPerlin), (double) modes[uni][j], (double) dynam[counter],(double) dur[counter] );
            /*if( (counter % 2) == 0) {
               for(int k=0; k < (chordpitches.length-1); k++) {
                 chordpitches[k] = modes[uni][j] + random(-1.5,1.5);//map(noise(tPerlin),0,1, -2,2);
               }
               piano.addChord(counter*0.5 + 2, chordpitches, chorddynam, chordur);
              }*/
        /*    else {
               piano.addNote(counter*0.5 + 4, ch, instr, modes[uni][j], dynam[counter], dur[counter], arti[counter], pans[counter] ); 
            }*/
              counter++;
              tPerlin += 0.05;
              pPerlin += 0.1;
              //println(counter); //+ (int)map(noise(tPerlin),0,1, -15, 10) )           
          }
    }
  }
  return counter;
}

//Generates the piano score
void makeMusic() {
  piano.stop(); //stop previous run, and empty the previous score
  //violin.stop();
  piano.empty();
  //violin.empty();
  int check;
  check = modeQuantize(pitches, modes, keyOffset, 0);
  println(check);
  //violin.play();
          
  if(check > 150) {
    int increment = (int)random(1, 3);
    cycle++;
    if( (uni + increment) > modes.length) {
      uni = (int) (uni+increment) - (int)(modes.length);
    }
    println(uni);
    check = modeQuantize(pitches, modes, keyOffset, uni);
    piano.play();
    //violin.play();    
  }
  //else if (check > 75 && cycle >= 3) { }            
   // piano.addCallback(8, 0);
} 

/*
//This function executes different code for generating variations in the music: if it takes too long to compute the scaled notes to be played, then repeat iteration by playing a chord to transition to another mode
//dur = 0.5*random(1,3);
void handleCallbacks(double startBeat, int callbackID) {
  if( tnew > (told + tdiff) ) {
    uni = random(0,2);
    //uni = (int)map(noise(tPerlin),0,1, 0,4) + (int)round(tnow % (told+tdiff));
    dynam += random(-15,16); //map(noise((tPerlin*2)%7),0,1,-15,16);
    mode = modes[uni];
    dur = durations[uni];
    
    tPerlin += 0.25;
    told = millis();
    makeMusic();
    piano.play();
  }
  else {
    
    
  }
} */
