function update(trackableObj,timeRaw,positionRaw,orientationRaw)
% The "update" method updates the real time properties of the trackable
% object "trackableObj".
%
% SYNTAX:
%   trackableObj = trackableObj.update()
%   trackableObj = trackableObj.update(timeRaw,positionRaw,orientationRaw)
%
% INPUTS:
%   trackableObj - (1 x 1 trackable.trackable)
%       An instance of the "trackable.trackable" class.
%
%   timeRaw - (1 x 1 number)
%       Time value to use for the update.
%
%   positionRaw - (3 x 1 number)
%       X, Y, Z position values to use for the update. 
%
%   orientationRaw - (1 x 1 quaternion or 4 x 1 number)
%       Quaternion object or A, B, C, D normalized quaternion values to use
%       for the update.
%   
% OUTPUTS:
%
% NOTES:
%   If arguments are provided, those argument values are used for the
%   update instead of querying the Optitrack system for data. This is
%   useful if it is desired to overload this method.
%
% NECESSARY FILES AND/OR PACKAGES:
%   +trackable, quaternion.m, getTrackableData.(mex file)
%
% SEE ALSO: TODO: Add see alsos
%    relatedFunction1 | relatedFunction2
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com) 24-OCT-2012
%-------------------------------------------------------------------------------

%% Check Input Arguments

% Check number of arguments
narginchk(1,4)
assert(nargin == 1 || nargin == 4,...
    'trackable:trackable:update:nargin',...
    'Incorrect number of input arguments')


% Check arguments for errors
assert(isa(trackableObj,'trackable.trackable') && numel(trackableObj) == 1,...
    'trackable:trackable:update:trackableObj',...
    'Input argument "trackableObj" must be a 1 x 1 "trackable.trackable" object.')

if nargin == 4
    assert(isnumeric(timeRaw) && isreal(timeRaw) && numel(timeRaw) == 1,...
        'trackable:trackable:update:timeRaw',...
        'Input argument "timeRaw" must be a scaler real number.')
    
    assert(isnumeric(positionRaw) && isreal(positionRaw) && numel(positionRaw) == 3,...
        'trackable:trackable:update:positionRaw',...
        'Input argument "positionRaw" must be a 3 x 1 vector of real numbers.')
    positionRaw = positionRaw(:);
    
    assert((isa(orientationRaw,'quaternion') && numel(orientationRaw) == 1 ) || ...
        (isnumeric(orientationRaw) && isreal(orientationRaw) && numel(orientationRaw) == 4),...
        'trackable:trackable:update:orientationRaw',...
        'Input argument "orientationRaw" must be a 1 x 1 quaternion or 4 x 1 vector of real numbers.')

    if ~isa(orientationRaw,'quaternion')
            orientationRaw = orientationRaw(:);
            if abs(norm(orientationRaw) - 1) > .01;
                warning('trackable:trackable:update:orientationRaw',...
                    'Property "orientationRaw" norm is not very close to 1. (Norm = %.3f)',norm(orientationRaw))
            end
            orientationRaw = orientationRaw / norm(orientationRaw);
            orientationRaw = quaternion(orientationRaw);
    end
end

%% Update
timePrev = trackableObj.timeRaw_;
posPrev = trackableObj.positionRaw_;
oriPrev = trackableObj.orientationRaw_;

if nargin == 1
    if trackableObj.validServer
        try
            trackableData = trackable.getTrackableData(trackableObj.device, trackableObj.host, trackableObj.port);
            
            trackableObj.timeRaw_ = toc(trackableObj.ticID);
            trackableObj.positionRaw_ = trackableData(1:3);
            trackableObj.orientationRaw_ = quaternion(trackableData(4:7));
            
            trackableObj.velocity = (trackableObj.positionRaw_ - posPrev) / (trackableObj.timeRaw_ - timePrev);
            
            trackableObj.validServer = true;
            
        catch %#ok<CTCH>
            trackableObj.validServer = false;
            warning('trackable:trackable:update:validServer',...
                'Properties were not updated because the server information is not valid or because the server is not broadcasting any valid data.')
        end
    end
    
else
    trackableObj.timeRaw_ = timeRaw;
    trackableObj.positionRaw_ = positionRaw;
    trackableObj.orientationRaw_ = orientationRaw;
    
    dt = trackableObj.timeRaw_ - timePrev;
    dp = (trackableObj.positionRaw_ - posPrev);
    dq = inv(oriPrev)*trackableObj.orientationRaw_; %#ok<MINV>
    [de,dtheta] = quaternion.quat2axis(dq.a,dq.b,dq.c,dq.d);
    if dtheta == 0
        de = zeros(3,1);
    end
    de = real(de); 
    
    trackableObj.velocity = dp / dt;
    trackableObj.angularVelocity = de / dt;
    
end

if trackableObj.tapeFlag
    trackableObj.writeToTape();
end

end
