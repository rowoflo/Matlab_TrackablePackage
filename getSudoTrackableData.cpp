// The "getTrackableData" function ...  TODO: Add description
//
// SYNTAX: TODO: Add syntax
//  output = getTrackableData(input1)
//  output = getTrackableData(input1,input2)
// 
// INPUTS: TODO: Add inputs
//  input1 - (size type) 
//      Description.
//
//  input2 - (size type) [defaultInputValue] 
//      Description for optional input.
// 
// OUTPUTS: TODO: Add outputs
//  output - (size type) 
//      Description.
//
// EXAMPLES: TODO: Add examples
//
// NOTES:
//
// NECESSARY FILES: TODO: Add necessary files
//  +trackable, someFile.m
//
// SEE ALSO: TODO: Add see alsos
//  relatedFunction1 | relatedFunction2
//
// COMPLILE COMMANDS:
//  mex -I/Applications/vrpn -L/Applications/vrpn/universal_macosx -lvrpn -lvrpnserver getTrackableData.cpp
//
// AUTHOR:
//    Rowland O'Flaherty (www.rowlandoflaherty.com)
//
// VERSION: 
//   Created 24-OCT-2012
//------------------------------------------------------------------------------

// Includes --------------------------------------------------------------------
#include <string>
#include "mex.h"
#include "vrpn_Analog.h"
//------------------------------------------------------------------------------


// Global definitions ----------------------------------------------------------
using namespace std;
double position[3];
bool newDataFlag;
//------------------------------------------------------------------------------


// Helper function definitions -------------------------------------------------
void VRPN_CALLBACK vrpn_analog_callback(void*, const vrpn_ANALOGCB analog);
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
    double *outMatrix;  //output matrix
    outputs[0] = mxCreateDoubleMatrix(3,1,mxREAL); //allocate memory // and assign output pointer
    outMatrix = mxGetPr(outputs[0]); //get a pointer to the real data // in the output matrix

    // Set input argument strings
    string device(mxArrayToString(inputs[0]));
    string host(mxArrayToString(inputs[1]));
    string port(mxArrayToString(inputs[2]));
    
    string connection = device + "@" + host + ":" + port;
    
    // VRPN object
    static vrpn_Analog_Remote* VRPNAnalog;
    
    // Bind VRPN Analog to callback
    VRPNAnalog = new vrpn_Analog_Remote(connection.c_str());
    VRPNAnalog->register_change_handler(NULL, vrpn_analog_callback);
    
    // Process main loop of the VRPN program
    int maxCnt = 1000;
    int sleepTime = 1000; // Micro seconds
    
    int cnt = 0;
    newDataFlag = false;
    while(!newDataFlag) {
        VRPNAnalog->mainloop();
        cnt++;
        if (cnt >= maxCnt) {
            mexErrMsgIdAndTxt("trackable:getTrackableData:noData",
                    "Unable to get data from server.");
        }
        usleep(sleepTime);
    }
    VRPNAnalog->mainloop();   
    
    // Output data
    outMatrix[0] = position[0];
    outMatrix[1] = position[1];
    outMatrix[2] = position[2];
    
}
//------------------------------------------------------------------------------


// Helper functions ------------------------------------------------------------
void VRPN_CALLBACK vrpn_analog_callback(void*, const vrpn_ANALOGCB analog) {
    position[0] = analog.channel[0];
    position[1] = analog.channel[1];
    position[2] = analog.channel[2];
    newDataFlag = true;
}
//------------------------------------------------------------------------------
