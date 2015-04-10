function validServer = validate(name,host,port)
% The "validate" function is used to validate the server information and
% that it is producing data.
%
% SYNTAX:
%   validServer = validate(name,host,port)
% 
% INPUTS:
%   name - (string)
%       Trackable name name.
%
%   host - (string)
%       Server computer host name.
%
%   port - (string) ['3883']
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
if nargin < 3; port = '3883'; end;
validServer = false;

% Check input arguments for errors
if ~(~isempty(name) && ischar(name))
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
    trackable.getTrackableData(name, host, port);
catch %#ok<CTCH>
    return
end

validServer = true;

end
