function motorValues = diffMorphic(diffdriveObj,setpoint)
% The "diffMorphic" method uses a diffeomorphism on the state to calculate
% control values to move the system towards the setpoint.
%
% SYNTAX:
%   motorValues = diffdriveObj.diffMorphic(setpoint)
%
% INPUTS: TODO: Add inputs
%   diffdriveObj - (1 x 1 diffdrive)
%       An instance of the "diffdrive" class.
%
%   setpoint - (6 x 1 number) 
%       Setpoint for controller in the form: [x; y; theta; vx; vy; omega].
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
%--------------------------------------------------------------------------

%% Parameters
l = .1;

%% Variables
% System state
x = diffdriveObj.position(1:2);
theta = diffdriveObj.orientation.yaw;
xBar = setpoint(1:2); % Setpoint
xTilde = xBar - x;
thetaBar = atan2(xTilde(2),xTilde(1));

% Diffmorphic state
z = x + l*[cos(theta); sin(theta)];
zBar = xBar + l*[cos(thetaBar); sin(thetaBar)];
zTilde = (z - zBar); 

% LQR
A = zeros(2);
B = [cos(theta) -l*sin(theta); sin(theta) l*cos(theta)];
Q = diag([10,10]);
R = diag([1;10]);

%% Calculate
K = lqr(A,B,Q,R);
u = -K*zTilde;

v = u(1);
w = u(2);

motorValues = diffdriveObj.linAngVel2motorValues(v,w);


end
