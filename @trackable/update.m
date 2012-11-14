function update(trackableObj)
% The "update" method updates the real time properties of the trackable
% object "trackableObj".
%
% SYNTAX:
%   trackableObj = trackableObj.update()
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
%   +trackable, getTrackableData.(mex file)
%
% SEE ALSO: TODO: Add see alsos
%    relatedFunction1 | relatedFunction2
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com) 24-OCT-2012
%-------------------------------------------------------------------------------

%% Check Input Arguments

% Check number of arguments
narginchk(1,1)

%% Update
if trackableObj.validServer
    try
        trackableData = trackable.getTrackableData(trackableObj.device, trackableObj.host, trackableObj.port);
        trackableObj.timeRaw_ = toc(trackableObj.ticID);
        trackableObj.positionRaw_ = trackableData(1:3);
        trackableObj.orientationRaw_ = trackableData(4:7);
        trackableObj.validServer = true;
    catch %#ok<CTCH>
        trackableObj.validServer = false;
        warning('trackable:trackable:update:validServer',...
            'Properties were not updated because the server information is not valid or because the server is not broadcasting any valid data.')
    end
end

if trackableObj.tapeFlag
    trackableObj.writeToTape();
end

end
