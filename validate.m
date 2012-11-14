function validServer = validate(device,host,port)
% The "validate" function is used to validate the server information and
% that it is producing data.
%
% SYNTAX:
%   validServer = validate(device,host,port)
% 
% INPUTS:
%   device - (string)
%       Trackable device name.
%
%   host - (string)
%       Server computer host name.
%
%   port - (string)
%       Server port number.
%
% OUTPUTS:
%   validServer - (1 x 1 logical) 
%       True if the server is valid and producing data.
%
% EXAMPLES:
%   trackable.validate('optitrackSudoServer','localhost','50555')
%
% NOTES:
%
% NECESSARY FILES:
%   trackable.getTrackableData
%
% SEE ALSO: TODO: Add see alsos
%    relatedFunction1 | relatedFunction2
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com)
%
% VERSION: 
%   Created 27-OCT-2012
%-------------------------------------------------------------------------------

%% Check Inputs
validServer = false;

% Check number of inputs
if nargin ~= 3
    return
end

% Check input arguments for errors
if ~(~isempty(device) && ischar(device))
    return
end

if ~(~isempty(host) && ischar(host))
    return
end

if ~(~isempty(port) && ischar(port))
    return
end

%% Validate
try
    trackable.getTrackableData(device, host, port);
catch %#ok<CTCH>
    return
end

validServer = true;

end
