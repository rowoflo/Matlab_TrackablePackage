function motorValues = setMoterValue(diffdriveObj,motorValues)
% The "setMoterValue" method sends the command to the diffdrive to set the
% current motor values.
%
% SYNTAX:
%   motorValues = diffdriveObj.setMoterValue(motorValues)
%
% INPUTS:
%   diffdriveObj - (1 x 1 diffdrive)
%       An instance of the "diffdrive" class.
%
%   motorValues - (2 x 1 0<=integer<=255) [[0;0]] 
%       Values to set the motors to.
%
% OUTPUTS:
%   motorValues - (2 x 1 0<=integer<=255)
%       The values the motors were actually set to
%
% NOTES:
%
% NECESSARY FILES AND/OR PACKAGES: TODO: Add necessary files
%   +package_name, someFile.m
%
% SEE ALSO: TODO: Add see alsos
%    relatedFunction1 | relatedFunction2
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com) 13-FEB-2015
%--------------------------------------------------------------------------

%% Check Input Arguments

% Check number of arguments
narginchk(1,2)

% Apply default values
if nargin < 2, motorValues = [0;0]; end

% Check arguments for errors
assert(isnumeric(motorValues) && isreal(motorValues) && numel(motorValues) == 2 && ...
    all(mod(motorValues,1) == 0) && ...
    all(motorValues >= diffdriveObj.motorLimits(1)) && all(motorValues <= diffdriveObj.motorLimits(2)),...
    'diffdrive:setMoterValue:motorValues',...
    'Property "motor" must be set to a 2 x 1 integer between %d and %d.',diffdriveObj.motorLimits(1),diffdriveObj.motorLimits(2))
motorValues = motorValues(:);

%% Set motor values
% if ~diffdriveObj.simulate
%     if diffdriveObj.connected
%         % Create command
%         command = sprintf('$SPD,%d,%d*\n', motorValues(1), motorValues(2));
%         fprintf(1,command);
%         % Send command
%         diffdriveObj.sendCommand(command);
%     else
%         warning('diffdrive:setMoterValue:notConnected',...
%             'Motor values not sent because not connected and simulator is off.');
%     end
% end

end
