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

%% Check Input Arguments
% 
% % Check number of arguments TODO: Add number argument check
% narginchk(1,inf)
% 
% % Apply default values TODO: Add apply defaults
% if nargin < 2, arg1 = 0; end
% 
% % Check arguments for errors TODO: Add error checks
% assert(isa(trackableObj,'trackable.trackable') && numel(trackableObj) == 1,...
%     'trackable:trackable:validate:trackableObj',...
%     'Input argument "trackableObj" must be a 1 x 1 "trackable.trackable" object.')
%
% assert(isnumeric(arg1) && isreal(arg1) && isequal(size(arg1),[?,?]),...
%     'trackable:trackable:validate:arg1',...
%     'Input argument "arg1" must be a ? x ? matrix of real numbers.')

%% Validate
trackableObj.validServer = trackable.validate(trackableObj.device,trackableObj.host,trackableObj.port);

end
