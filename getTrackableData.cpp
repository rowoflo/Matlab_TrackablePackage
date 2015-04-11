// The "getTrackableData" function grabs OptiTrack track data for a device and outputs it
//
// SYNTAX:
//  trackableData = getTrackableData(device,host,port)
// 
// INPUTS:
//  device - (string)
//      Trackable device name.
//
//  host - (string)
//      Server computer host name.
//
//  port - (string)
//      Server port number.
// 
// OUTPUTS:
//  trackableData - (7 x 1 number) 
//      Data vector holding position and orientation information. Position
//      cartesian x,y,z components are in trackableData(1:3) and orientation
//      quaterion i,j,k,r components are in trackableData(4:7).
//
// EXAMPLES:
//  trackableData = getTrackableData('BrushBot','192.168.1.145','3883')
//
// NOTES:
//
// NECESSARY FILES:
//  VRPN Library (https://github.com/vrpn/vrpn):
//      Mac OS X Install:
//      >> brew install vrpn
//
// SEE ALSO:
//
// COMPLILE COMMANDS:
//  Mac O
//  mex -I/usr/local/Cellar/vrpn/07.33/include -L/usr/local/Cellar/vrpn/07.33/lib -lvrpn -lvrpnserver getTrackableData.cpp
//
// AUTHOR:
//    Rowland O'Flahery (http://rowlandoflaherty.com)
//
// VERSION: 
//   Created 24-OCT-2012
//------------------------------------------------------------------------------

// Includes --------------------------------------------------------------------
#include "mex.h"
#include "vrpn_Tracker.h"
#include <string>
#include <iostream>
#include <unistd.h>

//------------------------------------------------------------------------------


// Global definitions ----------------------------------------------------------
using namespace std;
double position[3];
double orientation[4];
bool newDataFlag;
//------------------------------------------------------------------------------


// Helper function definitions -------------------------------------------------
void VRPN_CALLBACK vrpn_tracker_callback(void*, const vrpn_TRACKERCB tracker);
//------------------------------------------------------------------------------


// Main mex function -----------------------------------------------------------
void mexFunction( int nOutpus, mxArray *outputs[], int nInputs, const mxArray *inputs[] ) {
    
    /* Check Inputs */
    // Check number of inputs
    if (nInputs < 3) {
        mexErrMsgIdAndTxt("trackable:getTrackableData:nInputs",
                "Too few input arguments.");
    }
    if (nInputs > 3) {
        mexErrMsgIdAndTxt("trackable:getTrackableData:nInputs",
                "Too many input arguments.");
    }
    
    // Check input arguments for errors
    if ( (!mxIsChar(inputs[0]) || (mxGetM(inputs[0]) != 1 ) ) ||
            (!mxIsChar(inputs[1]) || (mxGetM(inputs[1]) != 1 ) ) ||
            (!mxIsChar(inputs[2]) || (mxGetM(inputs[2]) != 1 ) ) ) {
        mexErrMsgIdAndTxt("trackable:getTrackableData:inputNotString",
                "Input arguments must be a string.");
    }
    
    // Set output argument
    double *trackableData;  //output matrix
    outputs[0] = mxCreateDoubleMatrix(7,1,mxREAL); //allocate memory // and assign output pointer
    trackableData = mxGetPr(outputs[0]); //get a pointer to the real data // in the output matrix

    // Set input argument strings
    string device(mxArrayToString(inputs[0]));
    string host(mxArrayToString(inputs[1]));
    string port(mxArrayToString(inputs[2]));
    
    string connection = device + "@" + host + ":" + port;
    
    // VRPN object
    static vrpn_Tracker_Remote* VRPNTracker;
    
    // Bind VRPN Analog to callback
    VRPNTracker = new vrpn_Tracker_Remote(connection.c_str());
    VRPNTracker->register_change_handler(NULL, vrpn_tracker_callback);
    
    // Process main loop of the VRPN program
    int maxCnt = 1000;
    int sleepTime = 1000; // Micro seconds
    
    int cnt = 0;
    newDataFlag = false;
    while(!newDataFlag) {
        VRPNTracker->mainloop();
        cnt++;
        if (cnt >= maxCnt) {
            mexErrMsgIdAndTxt("trackable:getTrackableData:noData",
                    "Unable to get data from server.");
        }
        usleep(sleepTime);
    }
    VRPNTracker->mainloop();
    
    VRPNTracker->unregister_change_handler( NULL, vrpn_tracker_callback);
    
    // Output data
    trackableData[0] = position[0];
    trackableData[1] = position[1];
    trackableData[2] = position[2];
    trackableData[3] = orientation[0];
    trackableData[4] = orientation[1];
    trackableData[5] = orientation[2];
    trackableData[6] = orientation[3];    
}
//------------------------------------------------------------------------------


// Helper functions ------------------------------------------------------------
void VRPN_CALLBACK vrpn_tracker_callback(void*, const vrpn_TRACKERCB tracker) {
    position[0] = tracker.pos[0];
    position[1] = tracker.pos[1];
    position[2] = tracker.pos[2];
    orientation[0] = tracker.quat[0];
    orientation[1] = tracker.quat[1];
    orientation[2] = tracker.quat[2];
    orientation[3] = tracker.quat[3];
    newDataFlag = true;
}
//------------------------------------------------------------------------------
