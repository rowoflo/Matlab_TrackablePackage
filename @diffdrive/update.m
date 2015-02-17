function update(diffdriveObj)
% The "update" method overloads the trackable.trackable.update method. If
% in simulator mode, this methods gets updates from the simulator
% otherwises uses the trackable update method.
%
% SYNTAX:
%   diffdriveObj.update()
%
% INPUTS:
%   diffdriveObj - (1 x 1 diffdrive)
%       An instance of the "diffdrive" class.
%
% OUTPUTS:
%
% NOTES:
%
% NECESSARY FILES AND/OR PACKAGES:
%   +trackable
%
% SEE ALSO:
%    trackable.trackable.update
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com) 13-FEB-2015
%--------------------------------------------------------------------------

%% Check Input Arguments

% Check number of arguments
narginchk(1,1)

%% Update
if diffdriveObj.simulate
    if diffdriveObj.settingFlag
        [timeRaw,positionRaw,orientationRaw] = diffdriveObj.simulator(0);
    else
        [timeRaw,positionRaw,orientationRaw] = diffdriveObj.simulator();
    end
    
    diffdriveObj.timeSim_ = timeRaw;
    diffdriveObj.positionSim_ = positionRaw;
    diffdriveObj.orientationSim_ = orientationRaw;
    
    update@trackable.trackable(diffdriveObj,timeRaw,positionRaw,orientationRaw);
    
else
    if diffdriveObj.track
        update@trackable.trackable(diffdriveObj);
    end
end


end
