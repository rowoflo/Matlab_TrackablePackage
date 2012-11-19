classdef trackable < handle
% The "trackable.trackable" class is used in conjunction with the OptiTrack
% tracking system to get state information of OptiTrack trackable objects
% into Matlab.
%
% NOTES:
%   To get more information on this class type "doc trackable.trackable" into the
%   command window.
%
% NECESSARY FILES AND/OR PACKAGES:
%   +trackable, quaternion.m
%
% SEE ALSO: TODO: Add see alsos
%    relatedFunction1 | relatedFunction2
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com)
%
% VERSION: 
%   Created 24-OCT-2012
%-------------------------------------------------------------------------------

%% Properties ------------------------------------------------------------------
properties (GetAccess = public, SetAccess = private)
    device % (string) Trackable device name
    host % (string) Server computer host name
    port % (string) Server port number
    
    validServer = false % (1 x 1 logical) True if the server connection is valid
end

properties (Access = protected)
    ticID % (1 x 1 number) Tic ID used with toc to get current running time.
end

properties (Access = public, Hidden = true)
    figHandle = [] % (1 x 1 graphics object) Figure handle for plot
    axisHandle = [] % (1 x 1 graphics object) Axis handle for plot
    graphicsHandles = [] % (? x 1 graphics objects) Graphics handles for plot
end

properties (Access = private, Hidden = true)
    timeRaw_ = nan % (1 x 1 number) Raw time data
    timeOffset_ = 0 % (1 x 1 number) Time offset
    positionRaw_ = nan(3,1) % (3 x 1 number) Raw position data
    positionOffset_ = zeros(3,1) % (3 x 1 number) Position offset
    orientationRaw_ = quaternion(nan(4,1)) % (1 x 1 quaternion) Raw orientation data
    orientationOffset_ = quaternion([1;0;0;0]) % (1 x 1 quaternion) Orientation offset
end

properties (Dependent = true, SetAccess = public)
    time % (1 x 1 number) Current time
    position % (3 x 1 number) Current position. Cartesian (x,y,z)
    orientation % (1 x 1 quaternion) Current orientation.
end

properties (GetAccess = public, SetAccess = private)
    velocity = nan(3,1) % (3 x 1 number) Current velocity
    angularVelocity = nan(3,1) % (3 x 1 number) Current angular velocity
end

properties (Dependent = true, SetAccess = private)
    transform % (4 x 4 number) Homogeneous tranform matrix of current position and orientation.
end

properties (Access = public)
    tapeFlag = false % (1 x 1 logical) If true tape recorder is on.
end

properties (GetAccess = public, SetAccess = private)
    tapeLength = 0; % (1 x 1 positive integer) Length of record tapes.
end

properties (GetAccess = public, SetAccess = private, Hidden = true)
    timeTapeVec = nan(1,0) % (1 x ? number) Recording of update times.
    positionTapeVec = nan(3,0) % (3 x ? number) Recording of past positions.
    orientationTapeVec = quaternion.empty(1,0) % (1 x ? quaternion) Recording of past orientations.
    velocityTapeVec = nan(3,0) % (3 x ? number) Recording of past velocities.
end

properties (Dependent = true, SetAccess = private)
    timeTape % (1 x ? number) Recording of update times.
    positionTape % (3 x ? number) Recording of past positions.
    orientationTape % (1 x ? quaternion) Recording of past orientations.
end

properties (Dependent = true, SetAccess = private, Hidden = true)
   tapeVecSize % (1 x 1 positive integer) % Actual size of tape vectors
end

properties (GetAccess = public, SetAccess = private, Hidden = true) 
    tapeCatSize = 500; % (1 x 1 positive integer) % Size to increase tape vectors when they fill up
end

%% Constructor -----------------------------------------------------------------
methods
    function trackableObj = trackable(device,host,port)
        % Constructor function for the "trackable" class.
        %
        % SYNTAX:
        %   trackableObj = trackable(device,host,port)
        %
        % INPUTS:
        %   device - (string) [''] 
        %       Sets the "trackableObj.device" property.
        %
        %   host - (string) [''] 
        %       Sets the "trackableObj.host" property.
        %
        %   port - (string) [''] 
        %       Sets the "trackableObj.port" property.
        %
        % OUTPUTS:
        %   trackableObj - (1 x 1 trackable object) 
        %       A new instance of the "trackable.trackable" class.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        
        % Check number of arguments
        narginchk(0,3)

        % Apply default values
        if nargin < 1, device = ''; end
        if nargin < 2, host = ''; end
        if nargin < 3, port = ''; end

        % Check input arguments for errors
        assert(ischar(device),...
            'trackable:trackable:device',...
            'Input argument "device" must be a string.')
        
        assert(ischar(host),...
            'trackable:trackable:host',...
            'Input argument "host" must be a string.')
        
        assert(ischar(port),...
            'trackable:trackable:port',...
            'Input argument "port" must be a string.')
        
        
        % Assign properties
        trackableObj.device = device;
        if ~isempty(device) && ~isempty(host) && ~isempty(port)
            trackableObj.setServerInfo(device,host,port);
        end
        trackableObj.ticID = tic;
    end
end
%-------------------------------------------------------------------------------

%% Destructor ------------------------------------------------------------------
% methods (Access = public)
%     function delete(trackableObj)
%         % Destructor function for the "trackableObj" class.
%         %
%         % SYNTAX:
%         %   delete(trackableObj)
%         %
%         % INPUTS:
%         %   trackableObj - (1 x 1 trackable.trackable)
%         %       An instance of the "trackable.trackable" class.
%         %
%         % NOTES:
%         %
%         %-----------------------------------------------------------------------
%         
%     end
% end
%-------------------------------------------------------------------------------

%% Property Methods ------------------------------------------------------------
methods
    function trackableObj = set.tapeFlag(trackableObj,tapeFlag)  %#ok<*MCHV2>
        % Overloaded assignment operator function for the "tapeFlag" property.
        %
        % SYNTAX:
        %   trackableObj.tapeFlag = tapeFlag
        %
        % INPUT:
        %   tapeFlag - (1 x 1 real number)
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        assert((islogical(tapeFlag) && numel(tapeFlag) == 1) || ...
            strcmp(tapeFlag,'Off') || strcmp(tapeFlag,'On'),...
            'trackable:trackable:set:tapeFlag',...
            'Property "tapeFlag" must be set to a 1 x 1 logical.')
        
        if strcmp(tapeFlag,'Off')
            tapeFlag = false;
        elseif strcmp(tapeFlag,'On')
            tapeFlag = true;
        elseif ~tapeFlag
            trackableObj.writeToTape(nan,nan(3,1),nan(4,1));
        end
        trackableObj.tapeFlag = tapeFlag;
    end
    
    function trackableObj = set.time(trackableObj,time) 
        % Overloaded assignment operator function for the "time" property.
        %
        % SYNTAX:
        %   trackableObj.time = time
        %
        % INPUT:
        %   time - (1 x 1 real number)
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        assert(isnumeric(time) && isreal(time) && numel(time) == 1,...
            'trackable:trackable:set:time',...
            'Property "time" must be set to a 1 x 1 real number.')
        
        % Briefly turn off tape for this update
        tapeFlag = trackableObj.tapeFlag;
        if tapeFlag
            trackableObj.tapeFlag = 'Off';
            tapeFlag = 'On';
        else
            trackableObj.tapeFlag = 'Off';
            tapeFlag = 'Off';
        end
        trackableObj.update();
        trackableObj.tapeFlag = tapeFlag; % Reset tapeFlag
        
        if isnan(trackableObj.timeRaw_)
            trackableObj.timeRaw_ = time;
        end
        trackableObj.timeOffset_ = trackableObj.timeRaw_ - time;
        if trackableObj.tapeFlag
            trackableObj.writeToTape();
        end
    end
    
    function trackableObj = set.position(trackableObj,position) 
        % Overloaded assignment operator function for the "position" property.
        %
        % SYNTAX:
        %   trackableObj.position = position
        %
        % INPUT:
        %   position - (3 x 1 real number)
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        assert(isnumeric(position) && isreal(position) && numel(position) == 3,...
            'trackable:trackable:set:position',...
            'Property "position" must be set to a 3 x 1 real number.')
        position = position(:);
        
        % Briefly turn off tape for this update
        tapeFlag = trackableObj.tapeFlag;
        if tapeFlag
            trackableObj.tapeFlag = 'Off';
            tapeFlag = 'On';
        else
            trackableObj.tapeFlag = 'Off';
            tapeFlag = 'Off';
        end
        trackableObj.update();
        trackableObj.tapeFlag = tapeFlag; % Reset tapeFlag
        
        if any(isnan(trackableObj.positionRaw_))
            trackableObj.positionRaw_ = position;
        end
        trackableObj.positionOffset_ = trackableObj.positionRaw_ - position;
        if trackableObj.tapeFlag
            trackableObj.writeToTape();
        end
    end
    
    function trackableObj = set.orientation(trackableObj,orientation) 
        % Overloaded assignment operator function for the "orientation" property.
        %
        % SYNTAX:
        %   trackableObj.orientation = orientation
        %
        % INPUT:
        %   orientation - (1 x 1 quaternion or 4 x 1 real number with the norm equal to 1)
        %
        % NOTES:
        %   A warning is displayed if the norm of the argument
        %   "orientation" is greater than 0.01 units from from 1;
        %
        %-----------------------------------------------------------------------
        assert((isa(orientation,'quaternion') && numel(a) == 1 ) || ...
            (isnumeric(orientation) && isreal(orientation) && numel(orientation) == 4),...
            'trackable:trackable:set:orientation',...
            'Property "orientation" must be a 1 x 1 quaternion or a 4 x 1 real number.')
        
        if ~isa(orientation,'quaternion')
            orientation = orientation(:);
            if abs(norm(orientation) - 1) > .01;
                warning('trackable:trackable:set:orientation',...
                    'Property "orientation" norm is not very close to 1. (Norm = %.3f)',norm(orientation))
            end
            orientation = orientation / norm(orientation);
            orientation = quaternion(orientation);
        end
        
        % Briefly turn off tape for this update
        tapeFlag = trackableObj.tapeFlag;
        if tapeFlag
            trackableObj.tapeFlag = 'Off';
            tapeFlag = 'On';
        else
            trackableObj.tapeFlag = 'Off';
            tapeFlag = 'Off';
        end
        trackableObj.update();
        trackableObj.tapeFlag = tapeFlag; % Reset tapeFlag
        
        if isnan(trackableObj.orientationRaw_)
            trackableObj.orientationRaw_ = orientation;
        end
        
        % q1 = trackableObj.orientationRaw_;
        % q1 = [ q1(1), q1(2), q1(3), q1(4);...
        %       -q1(2), q1(1),-q1(4), q1(3);...
        %       -q1(3), q1(4), q1(1),-q1(2);...
        %       -q1(4),-q1(3), q1(2), q1(1)];
        % q2 = orientation;
        % q2 = [q2(1);-q2(2:4)];
        % trackableObj.orientationOffset_ = q1'*q2;
        
        trackableObj.orientationOffset_ = trackableObj.orientationRaw_ * conj(orientation);
        
        if trackableObj.tapeFlag
            trackableObj.writeToTape();
        end
    end

    function time = get.time(trackableObj)
        % Overloaded query operator function for the "time" property.
        %
        % SYNTAX:
        %	  time = trackableObj.time
        %
        % OUTPUT:
        %   time - (1 x 1 number)
        %       Time updated with offset.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        time = trackableObj.timeRaw_ - trackableObj.timeOffset_;
    end
    
    function position = get.position(trackableObj)
        % Overloaded query operator function for the "position" property.
        %
        % SYNTAX:
        %	  position = trackableObj.position
        %
        % OUTPUT:
        %   position - (3 x 1 number)
        %       Position updated with offset.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        position = trackableObj.positionRaw_ - trackableObj.positionOffset_;
    end
    
    function orientation = get.orientation(trackableObj)
        % Overloaded query operator function for the "orientation" property.
        %
        % SYNTAX:
        %	  orientation = trackableObj.orientation
        %
        % OUTPUT:
        %   orientation - (1 x 1 quaternion)
        %       Orientation updated with offset.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        
        % q1 = trackableObj.orientationRaw_;
        % q1 = [ q1(1), q1(2), q1(3), q1(4);...
        %       -q1(2), q1(1),-q1(4), q1(3);...
        %       -q1(3), q1(4), q1(1),-q1(2);...
        %       -q1(4),-q1(3), q1(2), q1(1)];
        % q2 = trackableObj.orientationOffset_;
        % q2 = [q2(1);-q2(2:4)];
        % orientation = q1'*q2;
        
        orientation = trackableObj.orientationRaw_ * conj(trackableObj.orientationOffset_);
%         if orientation.d < 0
%             orientation = conj(orientation);
%         end
    end
    
    function transform = get.transform(trackableObj)
        % Overloaded query operator function for the "transform" property.
        %
        % SYNTAX:
        %	  transform = trackableObj.transform
        %
        % OUTPUT:
        %   transform - (4 x 4 number)
        %       Homogenous transform matrix.
        %
        % NOTES:
        %   See http://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
        %
        %-----------------------------------------------------------------------
        
        p = trackableObj.position;
        q = trackableObj.orientation;
        r = rot(q);
        % a = q(1); b = q(2); c = q(3); d = q(4);
        % r = [a^2+b^2-c^2-d^2    2*b*c-2*a*d     2*b*d+2*a*c;...
        %      2*b*c+2*a*d        a^2-b^2+c^2-d^2 2*c*d-2*a*b;...
        %      2*b*d-2*a*c        2*c*d+2*a*b     a^2-b^2-c^2+d^2];
        transform = [r p;[zeros(1,3) 1]];
    end
    
    function timeTape = get.timeTape(trackableObj)
        % Overloaded query operator function for the "timeTape" property.
        %
        % SYNTAX:
        %	  timeTape = trackableObj.timeTape
        %
        % OUTPUT:
        %   timeTape - (1 x ? number)
        %       Time record vector.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        
        timeTape = trackableObj.timeTapeVec(:,1:trackableObj.tapeLength);
    end
    
    function positionTape = get.positionTape(trackableObj)
        % Overloaded query operator function for the "positionTape" property.
        %
        % SYNTAX:
        %	  positionTape = trackableObj.positionTape
        %
        % OUTPUT:
        %   positionTape - (1 x ? number)
        %       Position record vector.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        
        positionTape = trackableObj.positionTapeVec(:,1:trackableObj.tapeLength);
    end
    
    function orientationTape = get.orientationTape(trackableObj)
        % Overloaded query operator function for the "orientationTape" property.
        %
        % SYNTAX:
        %	  orientationTape = trackableObj.orientationTape
        %
        % OUTPUT:
        %   orientationTape - (1 x ? number)
        %       Orientation record vector.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        
        orientationTape = trackableObj.orientationTapeVec(:,1:trackableObj.tapeLength);
    end
    
    function tapeVecSize = get.tapeVecSize(trackableObj)
        % Overloaded query operator function for the "tapeVecSize" property.
        %
        % SYNTAX:
        %	  tapeVecSize = trackableObj.tapeVecSize
        %
        % OUTPUT:
        %   tapeVecSize - (1 x 1 positive integer)
        %       Orientation record vector.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        
        tapeVecSize = size(trackableObj.timeTapeVec,2);
    end
end
%-------------------------------------------------------------------------------

%% General Methods -------------------------------------------------------------
methods (Access = public)
    function validServer = setServerInfo(trackableObj,device,host,port)
        % The "setServerInfo" method updates the server information for
        % this trackable object.
        %
        % SYNTAX:
        %   validServer = trackableObj.setServerInfo(device,host,port)
        %
        % INPUTS:
        %   trackableObj - (1 x 1 trackable.trackable)
        %       An instance of the "trackable.trackable" class.
        %
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
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(4,4)
        
        % Check arguments for errors
        assert(~isempty(device) && ischar(device),...
            'trackable:trackable:setServerInfo:device',...
            'Input argument "device" must be a non-empty string.')
        
        assert(~isempty(host) && ischar(host),...
            'trackable:trackable:setServerInfo:host',...
            'Input argument "host" must be a non-empty string.')
        
        assert(~isempty(port) && ischar(port),...
            'trackable:trackable:setServerInfo:port',...
            'Input argument "port" must be a non-empty string.')
        
        trackableObj.device = device;
        trackableObj.host = host;
        trackableObj.port = port;
        trackableObj.validate();
        validServer = trackableObj.validServer;
    end
    
%     function setTime(trackableObj,time)
%         % The "resetTime" method sets the time to the given value.
%         %
%         % SYNTAX:
%         %   trackableObj.resetTime()
%         %   trackableObj.resetTime(time) [0]
%         %   
%         %
%         % INPUTS:
%         %   trackableObj - (1 x 1 trackable.trackable)
%         %       An instance of the "trackable.trackable" class.
%         %
%         %   time - (1 x 1 number)
%         %       The value that the time will be set to.
%         %
%         % NOTES:
%         %
%         %-----------------------------------------------------------------------
%         
%         % Check number of arguments
%         narginchk(1,2)
%         
%         % Apply default values
%         if nargin < 2, time = 0; end
%         
%         % Check arguments for errors
%         assert(isnumeric(time) && isreal(time) && numel(time) == 1,...
%             'trackable:trackable:setTime:time',...
%             'Input argument "time" must scaler real valued number.')
%         
%         trackableObj.time0_ = toc(trackableObj.ticID) - time;
%         
%     end
end

methods (Access = private)
    function writeToTape(trackableObj,time,position,orientation)
        % The "writeToTape" method sets adds data to the tape properties.
        %
        % SYNTAX:
        %   trackableObj.writeToTape(time,position,orientation)
        %
        % INPUTS:
        %   trackableObj - (1 x 1 trackable.trackable)
        %       An instance of the "trackable.trackable" class.
        %
        %   time - (1 x 1 number)
        %       Time value recorded to the "timeTape" property.
        %
        %   position - (1 x 1 number)
        %       Position value recorded to the "positionTape" property.
        %
        %   orientation - (1 x 1 number)
        %       Orientation value recorded to the "orientationTape" property.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        
        if nargin < 2, time = trackableObj.time; end
        if nargin < 3, position = trackableObj.position; end
        if nargin < 4, orientation = trackableObj.orientation; end
        
        if trackableObj.tapeLength + 1 > trackableObj.tapeVecSize % Increase vector size
            trackableObj.timeTapeVec = [trackableObj.timeTapeVec nan(1,trackableObj.tapeCatSize)];
            trackableObj.positionTapeVec = [trackableObj.positionTapeVec nan(3,trackableObj.tapeCatSize)];
            trackableObj.orientationTapeVec = [trackableObj.orientationTapeVec repmat(quaternion(nan(4,1)),1,trackableObj.tapeCatSize)];
        end
        trackableObj.tapeLength = trackableObj.tapeLength + 1;
        trackableObj.timeTapeVec(:,trackableObj.tapeLength) = time;
        trackableObj.positionTapeVec(:,trackableObj.tapeLength) = position;
        trackableObj.orientationTapeVec(:,trackableObj.tapeLength) = orientation;
    end
end
%-------------------------------------------------------------------------------

%% Methods in separte files ----------------------------------------------------
methods (Access = public)
    validate(trackableObj)
    update(trackableObj,timeRaw,positionRaw,orientationRaw)
    plot(trackableObj)
end
%-------------------------------------------------------------------------------
    
end
