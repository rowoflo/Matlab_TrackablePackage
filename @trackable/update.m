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
%   +trackable, quaternion.m, getTrackableData.(mex file)
%
% SEE ALSO: TODO: Add see alsos
%    relatedFunction1 | relatedFunction2
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com) 21-FEB-2015
%-------------------------------------------------------------------------------

%% Update

if trackableObj.simulate
    [pos,ori] = trackableObj.simUpdateHandle(trackableObj);
    trackableObj.position = pos;
    trackableObj.orientation = ori;
    trackableObj.time = trackableObj.time + trackableObj.simTimeStep;
else
    if trackableObj.validServer
        try
            trackable.getTrackableData(trackableObj.name, trackableObj.host, trackableObj.port); % FIXME: Needs to be fixed. Currently takes two updates to get data.
            optiData = trackable.getTrackableData(trackableObj.name, trackableObj.host, trackableObj.port);
            
            x = optiData(1);
            y = optiData(2);
            z = optiData(3);
            
            i = optiData(4);
            j = optiData(5);
            k = optiData(6);
            r = optiData(7);
            
            trackablePos = trackableObj.orientationGlobalRotation_ * [x;y;z];
            trackableQuat = (trackableObj.orientationGlobalRotation_' * quaternion([r i j k])) * trackableObj.orientationLocalRotation_;
            
            trackableObj.timeRaw_ = toc(trackableObj.ticID);
            trackableObj.positionRaw_ = trackableObj.coordOrientation.rot * (trackableObj.coordScale .* trackablePos);
            trackableObj.orientationRaw_ = trackableObj.coordOrientation * trackableQuat;
            
            trackableObj.validServer = true;
            
        catch exception
            if strcmp(exception.identifier,'trackable:getTrackableData:noData')
                trackableObj.validServer = false;
                warning('trackable:trackable:update:validServer',...
                    'Properties were not updated because the server information is not valid or because the server is not broadcasting any valid data.')
            else
                rethrow(exception)
            end
        end
    else
        trackableObj.validate();
    end
end
end
