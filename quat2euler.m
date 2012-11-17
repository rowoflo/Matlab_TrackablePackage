function euler = quat2euler(quat)
% The "quat2euler" function converts a quaterion to a Euler angles.
%
% SYNTAX:
%   euler = trackable.quat2euler(quat)
% 
% INPUTS:
%   quat - (4 x 1 number) 
%       Is a normalized quaterion. With components quat = [a;b;c;d] from
%       the form quat = a + bi + cj + dk and norm(quat) = 1.
% 
% OUTPUTS:
%   euler - (3 x 1 number) 
%       Euler angles [phi; theta; psi] for the given quaterion.
%
% EXAMPLES: TODO: Add examples
%
% NOTES:
%   See http://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
%
% NECESSARY FILES:
%
% SEE ALSO:
%    trackable.euler2quat | trackable.quat2rot | trackable.rot2quat
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com)
%
% VERSION: 
%   Created 14-NOV-2012
%-------------------------------------------------------------------------------

%% Check Inputs

% Check number of inputs
narginchk(1,1)

% Check input arguments for errors TODO: Add error checks
assert(isnumeric(quat) && isreal(quat) && numel(quat) == 4,...
    'trackable:quat2euler:quat',...
    'Input argument "quat" must be a 4 x 1 vector of real numbers with a norm of 1.')
quat = quat(:);
if abs(norm(quat) - 1) > .01
    warning('trackable:quat2euler:quat',...
        'Input argument "quat" norm is not very close to 1. (Norm = %.3f)',norm(quat))
end
quat = quat / norm(quat);


%% Convert from quaterion to Euler angles
a = quat(1); b = quat(2); c = quat(3); d = quat(4);

phi = atan2(2*(a*b+c*d),1-2*(b^2+c^2));
theta = asin(2*(a*b-d*c));
psi = atan2(2*(a*d+b*c),1-2*(c^2+d^2));

euler = [phi theta psi]';

end
