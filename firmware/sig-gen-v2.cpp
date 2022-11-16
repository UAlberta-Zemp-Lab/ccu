/*
   This program is written for SigGen arduino.
   Made by Afshin K. I.
   all variabled start with uppercase letter
   all functions start with lowercase letter
   all defined pins start with pinXXX
   all serial definitions start with serialXXX


   HOW PA imaging will be done!
  Verasonics will generate a trigger and it will be fed to Trigger 2 on CCU
  when trigger 2 received,CCU will generate all the nessesary pulses when 10Hz pulse is generated on the rising edge!
  Verasonics will wait until it received trigger from CCU
  at the same time laser will receive the timed pulse for qSwitch and will shoot out a pulse
  verasonics will record the pulse,
  after 500us, CCU will create a pulse on Delay 4 that will be fed back to trigger 1, this will generate a trigger for cards to count up the sequence!
  if verasonics generated another tigger, CCU will forward it to Delay 4 and it will goto trigger in, CCU will wait 80us, and will provide another trigger out to veasonics only
  Veasonics can perform as many ultraound frame as possible from 1 ms to 99 ms from the trigger


   10HZ will go to Verasonics
   triggerOut will go to verasonics  and will happen at with a delay of  300 + TrOd
   Delay 1 will also goto laser  will be based on Qswitch
   Delay 2 will have a copy of 10Hz and will gor to laser
   Delay 3 can be connected to Aquzation card or a PD and will have a similar 10Hz wave
   Delay 4 will be connected to Trigger in 1  to provide a trigger to the cards to change the bias
   Trigger 2 can be connected to verasonics to perfom US while waiting for laser if wanted

   +++++++++++++++++++++++++++++++++++++++++++++++++++++
   IMPORTANT
   AUTO TrOd must be fixed   <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
   pinOK function and interupt must be written <<<<<<<<<<<<<<<<<<<<<<<<<<


*/


//Definitions and includes
#define SerialHUB Serial1
#define SerialPS1 Serial3
#define SerialPS2 Serial2

// Create an IntervalTimer object
IntervalTimer my10HzGeneratorTimer;
IntervalTimer myTriggerOutTimer;
IntervalTimer myQswitchGeneratorTimer;
IntervalTimer ledBlinkTimer;


//Pin configurations
const byte pinOK = 4;    // OK line controlled by CCU, 1 means STOP, 0 means continue whatever was happining, FALLING means new data has sent, confirm the data.
const byte pinTrg1 = 5;   // Main input trigger line, that can be deacctivated
const byte pinTrg2 = 6;   // Secondsry trigger line that can be acctivated
const byte pinPdly1 = 9; // Programmable Delay out 1, ONLY used for PA imaging
const byte pinPdly2 = 10; // Programmable Delay out 2
const byte pinPdly3 = 11; // Programmable Delay out 2
const byte pinPdly4TrO = 12; // Programmable Delay out 2
const byte pinTrO = 18;
const byte pinHzOut = 19; // 10HZ out for PA imaging
const byte pinDir1 = 22; // Controll direction of 10HZ and TrO
const byte pinDir2 = 21; // Controll direction of delay1 and 2
const byte pinDir3 = 20; // Controll direction of delay3 and 4
const byte pinLED = 13;


//Variables for Signal Generator
byte ReceivedData[64]; //Every receive from
byte StatData[64]; // will contain the stat data to be transmited
volatile byte VNN;  // 1 value from verasonics, 2 read from CCU, 3~6 read from cards
volatile byte VPP;  // 1 value from verasonics, 2 read from CCU, 3~6 read from cards
volatile word VPPc;   //current settings
volatile word VNNc;   //current settings
volatile bool Trg1;
volatile bool Trg2;
volatile bool ImgMd;
volatile bool STOP = 1; // at the beginning stop signal generation
volatile bool Intiation;
volatile bool Operation;
volatile word TrOd = 50; //Dummy value
volatile word Qswitch = 500;
volatile bool VPPactive=false;
volatile bool VNNactive=false;
volatile bool F10HzOutState=false;
volatile byte QswitchState=0;
volatile bool FirstTrigger=true;

volatile bool Dly1En;      volatile bool Dly2En;      volatile bool Dly3En;      volatile bool Dly4En;      volatile bool Dly2Inv;
volatile word Dly1IniD;    volatile word Dly2IniD;    volatile word Dly3IniD;    volatile word Dly4IniD;    volatile bool Dly3Inv;
volatile float Dly1lengthD = 508; volatile word Dly2lengthD; volatile word Dly3lengthD; volatile word Dly4lengthD; volatile bool Dly4Inv;
volatile byte Freq10HzState = 0; //this is used to track the timer state
volatile word TrOdTimerState = 0; //this is used to track the timer state
volatile byte DlyintervalsNum = 0; // this will be calculated based on the enabled dlys
volatile byte Dlyintervalscount = 0; // this will be calculated based on the enabled dlys
volatile word Tdlyint[6]; // this will be calculated based on the enabled dlys
volatile byte TdlyOrder[6]; // this will be calculated based on the enabled dlys
volatile int SeqCount = 0; // count the sequences will be added up by trigger 1 interrups
volatile bool triggerOutState = 0; // if this bit is 1, then mean trigger is generated and timer must be turned off
volatile bool PAtoken = 0;   // this token will be created with trigger 2 and if it is true, delayed pulses will be performed
volatile bool AfterStopPulse=0; //this will determin is there any trigger waiting to be set to verasonics
byte updateVariable[64];      // this variable will contain lastest data and ready to transmit on request
bool Permission = false;
bool PermissonState = false;
volatile bool StartAtimedTrigger=false;
unsigned long StoreTime=0;

void setup() {
  /* future stuff:
      Pin 4 will be comtrolled by the HUB, if it is 1, proccess must be stopped, if its falling, it means serial has a value to read
  */
  //pin configuration
  pinMode(pinLED, OUTPUT);
  pinMode(pinOK, INPUT_PULLUP);
  pinMode(pinHzOut, OUTPUT);
  pinMode(pinTrO, OUTPUT);
  pinMode(pinPdly1, OUTPUT);
  pinMode(pinPdly2, OUTPUT);
  pinMode(pinPdly3, OUTPUT);
  pinMode(pinPdly4TrO, OUTPUT);
  pinMode(pinDir1, OUTPUT);
  pinMode(pinDir2, OUTPUT);
  pinMode(pinDir3, OUTPUT);
  pinMode(pinTrg1, INPUT_PULLUP);  // will be used only for PA
  pinMode(pinTrg2, INPUT_PULLUP);  // will be used only for PA

  //intial pin state
  digitalWrite(pinLED, LOW);
  digitalWrite(pinHzOut, LOW);
  digitalWrite(pinTrO, LOW);
  digitalWrite(pinPdly1, HIGH);
  digitalWrite(pinPdly2, LOW);
  digitalWrite(pinPdly3, LOW);
  digitalWrite(pinPdly4TrO, LOW);
  digitalWrite(pinDir1, LOW);
  digitalWrite(pinDir2, LOW);
  digitalWrite(pinDir3, LOW);

  //attach interups
  attachInterrupt(digitalPinToInterrupt(pinTrg1), Trigger1Interrup, FALLING);   // main trigger, if comes in and CCU confirms, a delayed trigger out will be created and counted
   attachInterrupt(digitalPinToInterrupt(pinTrg2), Trigger2Interrup, FALLING);  // secondary trigger that needs to be used for PA imaging ONLY
  attachInterrupt(digitalPinToInterrupt(pinOK), pinOKInterrup, RISING);    // this pin will be controlled by hub, rising, will stop the process, turn STOP to 1, nyut last 1 us
  ledBlinkTimer.begin(blinkLED, 500000);

  //setup hardware serials
  Serial.begin(9600);
  SerialHUB.begin(9600);  //Serial connected to the hub
  SerialPS1.begin(9600);  //Serial connected to the hub
  SerialPS2.begin(9600);  //Serial connected to the hub




  //extras   remove after code develoupment



  Permission = digitalRead(pinOK);
  PermissonState = Permission;


}

//main loop
void loop() {
  Permission = digitalRead(pinOK);
  if (StoreTime==0) {
    STOP = !Permission;
  }
if ((StartAtimedTrigger)&&(VPP!=0||VNN!=0)){
  StoreTime=millis();
 StartAtimedTrigger=false; 
 STOP=1;
}

if((millis()>(StoreTime+5000))&&StoreTime!=0){
   StoreTime=0;
   STOP = 0;
 if ((VPP!=0||VNN!=0)&&(AfterStopPulse==1)){  
 digitalWrite(pinTrO, HIGH);  
 delayMicroseconds(6);
 digitalWrite(pinTrO, LOW);
}  
if (TrOd>0){
  delayMicroseconds(TrOd);
}else{
  delayMicroseconds(100); 
}
 if ((VPP!=0||VNN!=0)&&(AfterStopPulse==1)){  
 digitalWrite(pinPdly4TrO, HIGH);  
 delayMicroseconds(6);
 digitalWrite(pinPdly4TrO, LOW);
 AfterStopPulse=0;
}
}
  

if (SerialHUB.available() > 0) {
  readSerialBuffer();
  //sendVariablesToPC();
}

////////////////////////////////////////////////////////////////////////////////////////////////
//if for auto trigger generation, only one will be created for every Trigger 1 input.
if (triggerOutState) {   //this will turn the triggerout timer off after generating the trigger
  myTriggerOutTimer.end();
  triggerOutState = 0;
  TrOdTimerState = 0;
  if (Intiation) { //if initilization is zero, meaning that verasonics just lauch the program
    SeqCount = 1;
  } else {
    SeqCount = SeqCount + 1;
  }
}
////////////////////////////////////////////////////////////////////////////////////////////////





}



//Info extractor from incomming command
void readSerialBuffer(void) {
  if (SerialHUB.available() > 0) {
    SerialHUB.readBytes(ReceivedData, 64);
    if (ReceivedData[0] == 83 && ReceivedData[1] == 105 && ReceivedData[2] == 103 && ReceivedData[63] == 48) {
      SerialHUB.write(ReceivedData, 64);

      VNN = ReceivedData[15];
      VPP = ReceivedData[14];
      VPPc = ReceivedData[16] << 8;
      VPPc = VPPc + ReceivedData[17];
      VNNc = ReceivedData[18] << 8;
      VNNc = VNNc + ReceivedData[19];

      ImgMd = bitRead(ReceivedData[7], 0);   //zero  US, ONE> PA
      STOP = bitRead(ReceivedData[6], 0);
      Intiation = bitRead(ReceivedData[8], 0);
      Operation = bitRead(ReceivedData[9], 0);
      TrOd = ReceivedData[10] << 8;
      TrOd = TrOd + ReceivedData[11];
      Qswitch = ReceivedData[12] << 8;
      Qswitch = Qswitch + ReceivedData[13];
      VPPactive=bitRead(ReceivedData[20],0);
      VNNactive=bitRead(ReceivedData[21],0);

      if (Qswitch < 250) {
        Qswitch = 250;
      }

      Dly1lengthD = (((Qswitch) + 8)); //in nanoseconds

    }
    signalGeneration(ImgMd);
    programPSs();
  }
}

///////////////////////////////////////////////////////Enable signal generator for PA imaging
void signalGeneration(bool f10hz) {
  //timers initial setup
  FirstTrigger=true;
  if (f10hz) {
    //digitalWrite(pinPdly4TrO, LOW);
    my10HzGeneratorTimer.begin(my10HzGenerator,99990);  // 10Hz generator ___(1.07300us)___|---(10us)---|____(9,999,988.927)
    my10HzGeneratorTimer.update(99990);
    F10HzOutState = false;
    digitalWrite(pinHzOut, F10HzOutState);
    //  ledBlinkTimer.begin(blinkLED, 50000);  // 10Hz generator ___(1.07300us)___|---(10us)---|____(9,999,988.927)
  } else {
    my10HzGeneratorTimer.end();
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////
//PA imaging signal generator
void my10HzGenerator(void) {  //creates 10HZ pulses, it can also, can enable trigger out if needed

if (F10HzOutState){ //if output is high, we waited for 10 us
    F10HzOutState = false;
    digitalWrite(pinHzOut, F10HzOutState);
    my10HzGeneratorTimer.update(10);
    if (PAtoken){   //PA requested
      if(FirstTrigger){
     myQswitchGeneratorTimer.begin(myQswitchGenerator,5000); 
     myQswitchGeneratorTimer.update(5000); 
     QswitchState=2; 
        FirstTrigger=false;
      }else{
     myQswitchGeneratorTimer.begin(myQswitchGenerator,Qswitch); 
     myQswitchGeneratorTimer.update(Qswitch); 
     QswitchState=0; 
    }  
}else{              //if output is low means we waited for a long time
    F10HzOutState = true;
    digitalWrite(pinHzOut, F10HzOutState);
    my10HzGeneratorTimer.update(99990);
}
}
}
/////////////////////////////////////////////////////////////////////////////////////////////
void myQswitchGenerator(void){
  switch (QswitchState) {
    case 0:     //we waited qswitch
        digitalWrite(pinPdly1, LOW);
        digitalWrite(pinPdly4TrO, HIGH); 
        myQswitchGeneratorTimer.update(10);
        QswitchState=1; 

    case 1:     //10us on for qswitch pulse
        digitalWrite(pinPdly1, HIGH);
        digitalWrite(pinPdly4TrO, HIGH); 
        myQswitchGeneratorTimer.update(5000);
        QswitchState=2; 

    case 2:     //5ms wait for triger for picards
        digitalWrite(pinTrO, HIGH);
        myQswitchGeneratorTimer.update(10);
        QswitchState=3; 
        
    case 3:     //10us on for triger for picards
        digitalWrite(pinTrO, LOW);
        myQswitchGeneratorTimer.end();
        QswitchState=0;     

}
if(QswitchState>3){
  QswitchState=0;
}
}
/////////////////////////////////////////////////////////////////////////////////////////////
void Trigger1Interrup (void) {
  //this trigger will come only when PA is performing, it will come from verasonics, and it will give a token to generate delays for PA, for US, will generate out triggers!
  if(ImgMd){
  PAtoken = true;
  }else{
  myTriggerOutTimer.begin(myTriggerOut, 1);  // TrOd generator ___(Trod)___|--(1us)--|__________(TrOd-5)__  
    AfterStopPulse=!STOP;
  digitalWrite(pinTrO, AfterStopPulse);
  }
}
//////////////////////////////////////////////////////////////If timer waited enough, will generate trigger out for 5 us, it will be shotdown with main loop
void myTriggerOut (void) {   //Creates delayed trigger out
    TrOdTimerState = TrOdTimerState + 1;
    if(TrOdTimerState>5){
  digitalWrite(pinTrO, LOW);   
  AfterStopPulse=0;
  }
  if ((TrOdTimerState >= TrOd && TrOdTimerState < TrOd + 4)) {
  if (!ImgMd){  
    digitalWrite(pinPdly4TrO, !STOP);     //if step is on, then no trigger will be created!!!
  }
  }
  if (TrOdTimerState >= (TrOd + 5)) { //Stays 5 us ON and will be trurn off whenever CPU is not busy, no rush to trun it off ...
    if (!ImgMd){
    digitalWrite(pinPdly4TrO, LOW);
    }
    triggerOutState = 1;
  }
}
/////////////////////////////////////////////////////////////////provides token for 1 PA frame
void Trigger2Interrup (void) {
  //this trigger will come only when PA is performing, it will come from verasonics, and it will give a token to generate delays for PA, for US, will generate out triggers!
  if(ImgMd){
  PAtoken = true;
  }else{
  myTriggerOutTimer.begin(myTriggerOut, 1);  // TrOd generator ___(Trod)___|--(1us)--|__________(TrOd-5)__  
    AfterStopPulse=!STOP;
  digitalWrite(pinTrO, AfterStopPulse);
  }
}
/////////////////////////////////////////////////////////////////////////////////////////////

//extras
void blinkLED() {
  digitalWrite(pinLED, !digitalRead(pinLED));
  if (!STOP) {
    ledBlinkTimer.begin(blinkLED, 25000);
  } else {
    ledBlinkTimer.begin(blinkLED, 500000);
  }
}


void sendVariablesToPC(void) { //if you want, this can send info to PC for debugging, remove for final version
  Serial.print("VNN= "); Serial.println(VNN);
  Serial.print("VPP= "); Serial.println(VPP);
  Serial.print("VPPc= "); Serial.println(VPPc);
  Serial.print("VNNc= "); Serial.println(VNNc);
  Serial.print("Trigger1= "); Serial.println(Trg1);
  Serial.print("Trigger2= "); Serial.println(Trg2);
  Serial.print("Imaging Mode= "); Serial.println(ImgMd);
  Serial.print("STOP= "); Serial.println(STOP);
  Serial.print("Initiation= "); Serial.println(Intiation);
  Serial.print("Operation= "); Serial.println(Operation);
  Serial.print("TrOd= "); Serial.println(TrOd);
  Serial.print("Qswitch= "); Serial.println(Qswitch);
  Serial.print("Delay1 (ns)= "); Serial.println(Dly1lengthD);
  Serial.print("Sequence= "); Serial.println(SeqCount);
  Serial.print("Dly2En= "); Serial.print(Dly2En); Serial.print(" Dly2IniD= "); Serial.print(Dly2IniD); Serial.print(" Dly2lengthD= "); Serial.print(Dly2lengthD); Serial.print(" Dly2Inv= "); Serial.println(Dly2Inv);
  Serial.print("Dly3En= "); Serial.print(Dly3En); Serial.print(" Dly3IniD= "); Serial.print(Dly3IniD); Serial.print(" Dly3lengthD= "); Serial.print(Dly3lengthD); Serial.print(" Dly3Inv= "); Serial.println(Dly3Inv);
  Serial.print("Dly4En= "); Serial.print(Dly4En); Serial.print(" Dly4IniD= "); Serial.print(Dly4IniD); Serial.print(" Dly4lengthD= "); Serial.print(Dly4lengthD); Serial.print(" Dly4Inv= "); Serial.println(Dly4Inv);
  Serial.print("SerialHUB.available()="); Serial.println(SerialHUB.available());
}

//Program PSs
void programPSs (void){

String Value="V1 ";
 SerialPS1.println("IFLOCK");
 SerialPS2.println("IFLOCK");
 Value="V1 ";
 Value=Value+String(VPP);
 SerialPS1.println(Value);
 Value="V1 ";
 Value=Value+String(VNN);
 SerialPS2.println(Value);
 Serial.println(Value);
 Value="I1 ";
 Value=Value+String(VPPc)+"e-3";
 SerialPS1.println(Value);
  Serial.println(Value);
 Value="I1 ";
 Value=Value+String(VNNc)+"e-3";
 SerialPS2.println(Value);
  Serial.println(Value);
   if (VPPactive) {
   SerialPS1.println("OP1 1");
  } else {
   SerialPS1.println("OP1 0");
  } 
   if (VNNactive) {
   SerialPS2.println("OP1 1");
  } else {
   SerialPS2.println("OP1 0");
  } 
  
}

void pinOKInterrup (void){
StartAtimedTrigger=true;  
}
