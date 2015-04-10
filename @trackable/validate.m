function validate(trackableObj)
% The "validate" method validates the current server settings.
%
% SYNTAX:
%   trackableObj = trackableObj.validate()
%
% INPUTS:
%   trackableObj - (1 x 1 trackable.trackable)
%       An instance of the "trackable.trackable" class.
%
% OUTPUTS:
%
% NOTES:
%
% NECESSARY FILES AND/OR PACKAGES:
%   +trackable,
%
% SEE ALSO:
%    trackable.update
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com) 03-NOV-2012
%-------------------------------------------------------------------------------

%% Validate
trackableObj.validServer = trackable.validate(trackableObj.name,trackableObj.host,trackableObj.port);

end
