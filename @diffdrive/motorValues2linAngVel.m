function [v,w] = motorValues2linAngVel(diffdriveObj,motorValues)
% The "motorValues2linAngVel" method converts left and right motor values
% to linear and angular velocities.
%
% SYNTAX:
%   [linVel,angVel] = diffdriveObj.motorValues2linAngVel(motorValues)
%
% INPUTS:
%   diffdriveObj - (1 x 1 trackable.diffdrive)
%       An instance of the "trackable.diffdrive" class.
%
%   motorValues - (2 x 1 integers)
%       Motor values [left; right].
%
% OUTPUTS:
%   v - (1 x 1 number)
%       Linear velocity.
%
%   w - (1 x 1 number)
%       Angular velocity.
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
narginchk(2,2)

%% Variables
r = diffdriveObj.wheelRadius;
b = diffdriveObj.wheelBase;
s = diffdriveObj.speedFactor;

%% Calculate
% Use model from "Intro to Autonomous Mobile Robots" text book section 3.2.2 page 61
wheelL = motorValues(1)/s;
wheelR = motorValues(2)/s;
v = r/2*(wheelR+wheelL);
w = r/(2*b)*(wheelR-wheelL);

end
