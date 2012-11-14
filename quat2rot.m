function rot = quat2rot(quat)
% The "quat2rot" function converts a quaterion to a rotation matrix.
%
% SYNTAX:
%   rot = trackable.quat2rot(quat)
% 
% INPUTS:
%   quat - (4 x 1 number) 
%       Is a normalized quaterion. With components quat = [a;b;c;d] from
%       the form quat = a + bi + cj + dk and norm(quat) = 1
% 
% OUTPUTS:
%   rot - (3 x 3 number) 
%       A standard rotation matrix that is in SO(3).
%
% EXAMPLES:
%     trackable.quat2rot([1 0 0 0]')
% 
%     ans =
%
%          1     0     0
%          0     1     0
%          0     0     1
%
% NOTES:
%   See http://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation
%
% NECESSARY FILES:
%
% SEE ALSO:
%    trackable.rot2quat
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com)
%
% VERSION: 
%   Created 12-NOV-2012
%-------------------------------------------------------------------------------

%% Check Inputs

% Check number of inputs
narginchk(1,1)

% Check input arguments for errors TODO: Add error checks
assert(isnumeric(quat) && isreal(quat) && numel(quat) == 4,...
    'trackable:quat2rot:quat',...
    'Input argument "quat" must be a 4 x 1 vector of real numbers with a norm of 1.')
quat = quat(:);
if abs(norm(quat) - 1) > .01
    warning('trackable:quat2rot:quat',...
        'Input argument "quat" norm is not very close to 1. (Norm = %.3f)',norm(quat))
end
quat = quat / norm(quat);

%% Convert from quaterion to rotation matrix
a = quat(1); b = quat(2); c = quat(3); d = quat(4);
rot = [a^2+b^2-c^2-d^2    2*b*c-2*a*d     2*b*d+2*a*c;...
       2*b*c+2*a*d        a^2-b^2+c^2-d^2 2*c*d-2*a*b;...
       2*b*d-2*a*c        2*c*d+2*a*b     a^2-b^2-c^2+d^2];

end
