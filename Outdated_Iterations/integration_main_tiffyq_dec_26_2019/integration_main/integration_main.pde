//integration_main_tiffyq_dec_26_2019 //<>//
import KinectPV2.*;
import java.lang.Long;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Iterator;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.Arrays; 

KinectPV2 kinect;

// for showing slides: 
PImage slide_YY_title; 
PImage slide_YP_title; 
PImage slide_YA_title;
PImage slide_YY_desc; 
PImage slide_YP_desc; 
PImage slide_YA_desc;
PImage slide_dancewithme;

final String YY_TITLE_PATH = "./YouVsYou_slide.png"; 
final String YP_TITLE_PATH = "./YouVsPrvs_slide.png"; 
final String YA_TITLE_PATH = "./YouVsAll_slide.png"; 
final String YY_DESC_PATH = "./YouVsYou_desc.png"; 
final String YP_DESC_PATH = "./YouVsPrvs_desc.png"; 
final String YA_DESC_PATH = "./YouVsAll_desc.png"; 
final String FINAL_SLIDE_PATH = "./dancewithme.png"; 
final int DISPLAY_TIME_TITLE = 3000; // 3 seconds 
final int DISPLAY_TIME_DESC = 3000; // 3 seconds
final int TIME_BETWEEN_RUN = 6000; //6 Seconds, minimum time between runs
final int TIME_USER_PRESENT = 6000; //6 seconds, how long a user must be detected before the program decides there is a human present

boolean showYY = true; 
boolean showYP = true; 
boolean showYA = true;
boolean showEndSlide = true;
boolean showYYdesc = true; 
boolean showYPdesc = true; 
boolean showYAdesc = true;
boolean YYsetUp = false;
boolean YPsetUp = false;
boolean YAsetUp = false;
boolean checkTime = true;
boolean checkTimeGlobal = true;
boolean checkUserPresence = true;
ArrayList<KSkeleton> body; //this is for checking if there is user present before running program again
int start; 
int start_global;
int start_user_presence;
int end; 

PFont britannicBold; 
int fontSize = 28; 
final int MARGIN = 10; 

boolean YY_finish = false;
boolean YP_finish = false;
boolean YA_finish = false;

// Used to save to database in a thread
boolean YA_savedToDatabase = false;

// start flag
boolean begin_dance = false;
// end flag, in order: YY, YP, YA, this is overkill right now, but I imagine these flags might be useful in the future.
boolean end_dance[] = {false, false, false}; //only YA is used right now for database along with YA_finish

void setup() {

  fullScreen(); 

  // Initialize Kinect
  kinect = new KinectPV2(this);
  kinect.enableBodyTrackImg(true);
  kinect.enableDepthImg(true);
  kinect.enableSkeletonColorMap(true); 
  kinect.enableSkeletonDepthMap(true); 
  kinect.init();

  slide_YY_title = loadImage(YY_TITLE_PATH); 
  slide_YP_title = loadImage(YP_TITLE_PATH); 
  slide_YA_title = loadImage(YA_TITLE_PATH); 
  slide_YY_desc = loadImage(YY_DESC_PATH); 
  slide_YP_desc = loadImage(YP_DESC_PATH); 
  slide_YA_desc = loadImage(YA_DESC_PATH); 
  slide_dancewithme = loadImage(FINAL_SLIDE_PATH); 

  // tiff: i changed this to arial cuz i got spooked about downloading a font from a not secure site lol :(
  britannicBold = createFont("Arial", fontSize); 
  textFont(britannicBold); 
  textAlign(LEFT, CENTER); 

  // this is to initialize YA_userId for use in creating output images
  YA_setup();
  YA_db.close();

  frameRate(16);
}

void draw() {

  //waiting time between rounds
  if (checkTimeGlobal) {
    start_global = millis();
    checkTimeGlobal = false;
  }

  //ensure there is a user present before running program 
  if (!begin_dance) {
    body = kinect.getSkeletonDepthMap();
  }
  if (body.size() > 0 && !begin_dance) {
    if (checkUserPresence) {
      start_user_presence = millis();
      checkUserPresence = false;
    }
  } else {
    if (!begin_dance) {
      start_user_presence = millis();
      checkUserPresence = true;
    }
  }

  //check if program should run now
  if ( !begin_dance && ((millis() - start_global)>TIME_BETWEEN_RUN) && ((millis() - start_user_presence)>TIME_USER_PRESENT) ) {
    begin_dance = true;
  }

  if (begin_dance) {
    // you vs you stage if selected
    if (YY_finish == false) {
      if (!YYsetUp) {
        YY_setup();
        YYsetUp = true;
      }
      if (checkTime) {
        start = millis(); 
        checkTime = false;
      }
      if (showYY) {
        image(slide_YY_title, 0, 0, width, height); 
        end = millis(); 
        if (end - start >= DISPLAY_TIME_TITLE) {
          showYY = false; 
          start = millis();
        }
      } else if (showYYdesc) {
        image(slide_YY_desc, 0, 0, width, height); 
        end = millis(); 
        if (end - start >= DISPLAY_TIME_DESC) {
          showYYdesc = false; 
          background(0);
        }
      } else {
        YY_draw();
        checkTime = true;
      }
    } 

    //begin you vs prev if selected
    if ( (YY_finish == true) && (YP_finish == false) ) {
      if (!YPsetUp) {
        YP_setup();
        YPsetUp = true;
      }
      if (checkTime) {
        start = millis(); 
        checkTime = false;
      }
      if (showYP) {
        image(slide_YP_title, 0, 0, width, height);
        end = millis(); 
        if (end - start >= DISPLAY_TIME_TITLE) {
          showYP = false; 
          start = millis();
        }
      } else if (showYPdesc) {
        image(slide_YP_desc, 0, 0, width, height); 
        end = millis(); 
        if (end - start >= DISPLAY_TIME_DESC) {
          showYPdesc = false; 
          background(0);
        }
      } else {
        YP_draw(); 
        checkTime = true;
      }
    } 

    //begin you vs all if selected
    if ( (YY_finish == true) && (YP_finish == true) && (YA_finish == false) ) {
      if (!YAsetUp) {
        YA_setup();
        YAsetUp = true;
      }
      if (checkTime) {
        start = millis(); 
        checkTime = false;
      }
      if (showYA) {
        image(slide_YA_title, 0, 0, width, height);
        end = millis(); 
        if (end - start >= DISPLAY_TIME_TITLE) {
          showYA = false; 
          start = millis();
        }
      } else if (showYAdesc) {
        image(slide_YA_desc, 0, 0, width, height); 
        end = millis(); 
        if (end - start >= DISPLAY_TIME_DESC) {
          showYAdesc = false; 
          background(0);
        }
      } else {
        YA_draw(); 
        checkTime = true;
      }
    }

    //ensure proper saving of database before moving on
    if (YA_finish) {
      if (YA_savedToDatabase) {
        end_dance[2] = true;
      }
    }

    // Begin final procedure
    if ( (YY_finish == true) && (YP_finish == true) && (end_dance[2] == true) ) {
      // Show the output images
      if (checkTime) {
        start = millis();
        checkTime = false;
      }
      end = millis();
      background(0);
      String YY_output_path = "./data/user" + YA_userId + "/1youvsyou.png";
      String YP_output_path = "./data/user" + YA_userId + "/2youvsprevious.png";
      String YA_output_path = "./data/user" + YA_userId + "/3youvsall.png";
      String YY_out_path_short = "./user" + YA_userId + "/1youvsyou.png";
      String YP_out_path_short = "./user" + YA_userId + "/2youvsprevious.png";
      String YA_out_path_short = "./user" + YA_userId + "/3youvsall.png";
      String DNE = "./data/DNE.png";

      textSize(24);
      if (end-start >= 1000) {
        PImage YY_output;
        if (dataFile(YY_out_path_short).exists()) {
          YY_output = loadImage(YY_output_path);
        } else {
          YY_output = loadImage(DNE);
        }
        image(YY_output, 50, 100, 256, 212);
        text("you vs. you", 50, 310);
      }
      if (end - start >= 2000) {
        PImage YP_output;
        if (dataFile(YP_out_path_short).exists()) {
          YP_output = loadImage(YP_output_path);
        } else {
          YP_output = loadImage(DNE);
        }
        image(YP_output, 384+50, 100, 256, 212);
        text("you vs. previous", 384+50, 310);
      }
      if (end - start >= 3000) {
        PImage YA_output;
        if (dataFile(YA_out_path_short).exists()) {
          YA_output = loadImage(YA_output_path);
        } else {
          YA_output = loadImage(DNE);
        }
        image(YA_output, 768+50, 100, 256, 212);
        text("you vs. all", 768+50, 310);
      }
      if (end - start >= DISPLAY_TIME_TITLE + 1000) {
        textSize(100);
        text("dancewithme", 100, 512);
      }

      //reset or exit the program
      if (end - start >= (DISPLAY_TIME_TITLE + 1000) && YA_savedToDatabase) {
        //exit();
        //return;
        reset_all_global();
      }
    }
  }
}