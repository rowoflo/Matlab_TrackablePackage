function quat = rot2quat(rot)
% The "rot2quat" function converts a rotation matrix to a quterion.
%
% SYNTAX:
%   quat = trackable.rot2quat(rot)
%   quat = trackable.rot2quat(rot,'PropertyName',PropertyValue,...)
% 
% INPUTS:
%   rot - (3 x 3 number) 
%       A standard rotation matrix that is in SO(3).
%
% PROPERTIES: TODO: Add properties
%   'propertiesName' - (size type) [defaultPropertyValue]
%       Description.
% 
% OUTPUTS:
%   quat - (4 x 1 number) 
%       Is a normalized quaterion. With components quat = [a;b;c;d] from
%       the form quat = a + bi + cj + dk and norm(quat) = 1
%
% EXAMPLES:
%     trackable.rot2quat(eye(3))
% 
%     ans =
% 
%          1
%          0
%          0
%          0
%
%
% NOTES:
%   See http://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation
%
% NECESSARY FILES:
%
% SEE ALSO:
%    trackable.quat2rot
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com)
%
% VERSION: 
%   Created 03-NOV-2012
%-------------------------------------------------------------------------------

%% Check Inputs

% Check number of inputs
narginchk(1,1)

% Check input arguments for errors
assert(isnumeric(rot) && isreal(rot) && isequal(size(rot),[3,3]),...
    'trackable.rot2quat:rot',...
    'Input argument "rot" must be a 3 x 3 matrix of real numbers in SO(3).')

if norm(rot'*rot - eye(3)) > .01
    warning('trackable:quat2rot:rot',...
        'Input argument "rot" is not very close to SO(3).')
end

% % Get and check properties
% propargin = size(varargin,2);
% 
% assert(mod(propargin,2) == 0,...
%     'rot2quat:properties',...
%     'Properties must come in pairs of a "PropertyName" and a "PropertyValue".')
% 
% propStrs = varargin(1:2:propargin);
% propValues = varargin(2:2:propargin);
% 
% for iParam = 1:propargin/2
%     switch lower(propStrs{iParam})
%         case lower('propertyName')
%             propertyName = propValues{iParam};
%         otherwise
%             error('rot2quat:options',...
%               'Option string ''%s'' is not recognized.',propStrs{iParam})
%     end
% end
% 
% % Set to default value if necessary TODO: Add property defaults
% if ~exist('propertyName','var'), propertyName = defaultPropertyValue; end
% 
% % Check property values for errors TODO: Add property error checks
% assert(isnumeric(propertyName) && isreal(propertyName) && isequal(size(propertyName),[1,1]),...
%     'rot2quat:propertyName',...
%     'Property "propertyName" must be a ? x ? matrix of real numbers.')

%% Convert
t = trace(rot);
r = sqrt(1+t);
s = 0.5/r;
w = 0.5*r;
x = (rot(3,2)-rot(2,3))*s;
y = (rot(1,3)-rot(3,1))*s;
z = (rot(2,1)-rot(1,2))*s;

quat = [w x y z]';

end
