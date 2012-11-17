function quat = euler2quat(euler)
% The "euler2quat" function converts a set of Euler angles to a quaterion.
%
% SYNTAX: TODO: Add syntax
%   quat = trackable.euler2quat(euler)
%   quat = trackable.euler2quat(euler,'PropertyName',PropertyValue,...)
% 
% INPUTS:
%   euler - (3 x 1 number) 
%       Euler angles [phi; theta; psi] for the given quaterion.
%
% PROPERTIES: TODO: Add properties
%   'propertiesName' - (size type) [defaultPropertyValue]
%       Description.
% 
% OUTPUTS:
%   quat - (4 x 1 number) 
%       Is a normalized quaterion. With components quat = [a;b;c;d] from
%       the form quat = a + bi + cj + dk and norm(quat) = 1.
%
% EXAMPLES: TODO: Add examples
%
% NOTES:
%   See http://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
%
% NECESSARY FILES:
%
% SEE ALSO:
%    trackable.quat2euler | trackable.quat2rot | trackable.rot2quat
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
assert(isnumeric(euler) && isreal(euler) && numel(euler) == 3,...
    'trackable:euler2quat:euler',...
    'Input argument "euler" must be a 3 x 1 vector of real numbers.')
euler = euler(:);

% % Get and check properties
% propargin = size(varargin,2);
% 
% assert(mod(propargin,2) == 0,...
%     'trackable:euler2quat:properties',...
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
%             error('trackable:euler2quat:options',...
%               'Option string ''%s'' is not recognized.',propStrs{iParam})
%     end
% end
% 
% % Set to default value if necessary TODO: Add property defaults
% if ~exist('propertyName','var'), propertyName = defaultPropertyValue; end
% 
% % Check property values for errors TODO: Add property error checks
% assert(isnumeric(propertyName) && isreal(propertyName) && isequal(size(propertyName),[1,1]),...
%     'trackable:euler2quat:propertyName',...
%     'Property "propertyName" must be a ? x ? matrix of real numbers.')

%% Conver from Euler angles to quaterion
phi = euler(1); theta = euler(2); psi = euler(3);

a = cos(phi/2)*cos(theta/2)*cos(psi/2) + sin(phi/2)*sin(theta/2)*sin(psi/2);
b = sin(phi/2)*cos(theta/2)*cos(psi/2) - cos(phi/2)*sin(theta/2)*sin(psi/2);
c = cos(phi/2)*sin(theta/2)*cos(psi/2) + sin(phi/2)*cos(theta/2)*sin(psi/2);
d = cos(phi/2)*cos(theta/2)*sin(psi/2) - sin(phi/2)*sin(theta/2)*cos(psi/2);

quat = [a b c d]';
end
