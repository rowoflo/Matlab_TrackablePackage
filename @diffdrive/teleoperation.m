function motorValues = teleoperation(diffdriveObj)
% The "teleoperation" method returns motor values based joystick input.
%
% SYNTAX:
%   motorValues = diffdriveObj.teleoperation()
%
% INPUTS:
%   diffdriveObj - (1 x 1 diffdrive)
%       An instance of the "diffdrive" class.
%
% OUTPUTS:
%   motorValues - (2 x 1 integers)
%       Motor values.
%
% NOTES:
%
% NECESSARY FILES AND/OR PACKAGES:
%   joystick.mex
%
% SEE ALSO: TODO: Add see alsos
%    relatedFunction1 | relatedFunction2
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com) 13-FEB-2015
%-------------------------------------------------------------------------------

%% Check Input Arguments

% Check number of arguments
narginchk(1,1)

%% Variables
mLim = diffdriveObj.motorLimits;
jLim = [0 32768];

%% Get joystick values
J = joystick();

jry = max(-J(4),jLim(1)); % Right Y joystick value
jly = max(-J(2),jLim(1)); % Left Y joystick value

%% Set motor values
m1 = floor(jry/jLim(2)*mLim(2));
m2 = floor(jly/jLim(2)*mLim(2));
fprintf(1,'M1 = %d, M2 = %d\n',m1,m2);
motorValues = [m1;m2];

end
