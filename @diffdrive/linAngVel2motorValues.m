function motorValues = linAngVel2motorValues(diffdriveObj,v,w)
% The "linAngVel2motorValues" method converts linear and angular velocities
% to left and right motor values.
%
% SYNTAX:
%   diffdriveObj = diffdriveObj.linAngVel2motorValues(linVel, angVel)
%
% INPUTS:
%   diffdriveObj - (1 x 1 trackable.diffdrive)
%       An instance of the "trackable.diffdrive" class.
%
%   v - (1 x 1 number)
%       Linear velocity.
%
%   w - (1 x 1 number)
%       Angular velocity.
%
% OUTPUTS:
%   motorValues - (2 x 1 integers)
%       Motor values [left; right].
%
% NOTES:
%
% NECESSARY FILES AND/OR PACKAGES: TODO: Add necessary files
%   +somePackage, someFile.m
%
% SEE ALSO: TODO: Add see alsos
%    relatedFunction1 | relatedFunction2
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com) 15-FEB-2015
%-------------------------------------------------------------------------------

%% Check Input Arguments

% Check number of arguments
narginchk(3,3)

%% Parameters

%% Variables
%Simulation Constants
r = diffdriveObj.wheelRadius;
b = diffdriveObj.wheelBase;
s = diffdriveObj.speedFactor;

maxVal = diffdriveObj.motorLimits(2);

%% Calculate
%Convert Speed and Angular Velocity to left and right wheel speeds
wheelR = (v + w*b)/r;
wheelL = (v - w*b)/r;

motorR = wheelR*s;
motorL = wheelL*s;

if abs(motorR) >= abs(motorL)
    if maxVal < abs(motorR)
        signVelL = sign(motorL);
        signVelR = sign(motorR);
        motorL = signVelL*(abs(motorL)*(maxVal/abs(motorR)));
        motorR = signVelR*maxVal;
    end
elseif abs(motorL) > abs(motorR)
    if maxVal < abs(motorL)
        signVelL = sign(motorL);
        signVelR = sign(motorR);
        motorR = signVelR*abs(motorR)*(maxVal/abs(motorL));
        motorL = signVelL*maxVal;
    end
end

motorValues = floor([motorL; motorR]);
end
