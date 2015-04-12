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
%    Rowland O'Flaherty (http://rowlandoflaherty.com)
%
% VERSION: 
%   Created 24-OCT-2012
%-------------------------------------------------------------------------------

%% Properties ------------------------------------------------------------------
properties (GetAccess = public, SetAccess = private)
    name % (string) Trackable name name
    host % (string) Server computer host/host name
    port = '3883'; % (string) Server port number
    validServer = false % (1 x 1 logical) True if the server connection is valid
    simulate = true; % (1 x 1 logical) If true runs in simulation.
    simTimeStep = .1; % (1 x 1 positive number) Time step used in simulation.
end

properties (Access = public)
    simUpdateHandle % (function handle) Function handle for trackable simulation update
end

properties (Access = protected)
    ticID % (1 x 1 number) Tic ID used with toc to get current running time.
end

properties (Access = public, Hidden = true)
    timeRaw_ = nan % (1 x 1 number) Raw time data
    timeOffset_ = 0 % (1 x 1 number) Time offset
    positionRaw_ = nan(3,1) % (3 x 1 number) Raw position data
    positionOffset_ = zeros(3,1) % (3 x 1 number) Position offset
    orientationRaw_ = quaternion(nan(4,1)) % (1 x 1 quaternion) Raw orientation data
    orientationOffset_ = quaternion([1;0;0;0]) % (1 x 1 quaternion) Orientation offset
    
    % Set to fix optitracks reference frame where Y is up to having Z as up.
    orientationLocalRotation_ = quaternion([1 0 0; 0 0 -1; 0 1 0]) % (1 x 1 quaternion) Transform from optitrack local reference frame to desired local reference frame.
    orientationGlobalRotation_ = quaternion([1 0 0; 0 0 -1; 0 1 0]) % (1 x 1 quaternion) Transform from optitrack global reference frame to desired global reference frame.
end

properties (Dependent = true, SetAccess = public)
    time % (1 x 1 number) Current time
    position % (3 x 1 number) Current position [Cartesian (x,y,z)]
    orientation % (1 x 1 quaternion) Current orientation
    x % (1 x 1 number) x position.
    y % (1 x 1 number) y position.
    z % (1 x 1 number) z position.
    roll % (1 x 1 number) roll angle.
    pitch % (1 x 1 number) pitch angle.
    yaw % (1 x 1 number) yaw angle.
end

properties (Access = public)
    coordScale = [1;1;1]; % (3 x 1 positive numbers) Scaling of raw coordinates (this is applied before coordinates are rotated to desired coordinates).
    coordOrientation = quaternion(); % (1 x 1 quaternion) Orientation of desired coordinates in raw coordinates.
end

%% Constructor -----------------------------------------------------------------
methods
    function trackableObj = trackable(simulate,name,host)
        % Constructor function for the "trackable" class.
        %
        % SYNTAX:
        %   trackableObj = trackable(simulate,name,host)
        %
        % INPUTS:
        %   simulate - (1 x 1 logical) [true]
        %       Sets the "simulate" property.
        %
        %   name - (string) [''] 
        %       Sets the "trackableObj.name" property.
        %
        %   host - (string) [''] 
        %       Sets the "trackableObj.host" property.
        %
        % OUTPUTS:
        %   trackableObj - (1 x 1 trackable object) 
        %       A new instance of the "trackable.trackable" class.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        
        % Check number of arguments
        narginchk(3,3)

        % Apply default values
        if nargin < 1, simulate = true; end;
        if nargin < 2, name = ''; end
        if nargin < 3, host = ''; end

        % Check input arguments for errors
        assert(ischar(name),...
            'trackable:trackable:name',...
            'Input argument "name" must be a string.')
        
        assert(ischar(host),...
            'trackable:trackable:host',...
            'Input argument "host" must be a string.')

        % Assign properties
        trackableObj.simulate = simulate;
        trackableObj.name = name;
        trackableObj.host = host;
        trackableObj.simUpdateHandle = @(trackableObj_) trackableObj_.simUpdate;
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
    function set.coordScale(trackableObj,coordScale)  %#ok<*MCHV2>
        % Overloaded assignment operator function for the "coordScale" property.
        %
        % SYNTAX:
        %   trackableObj.coordScale = coordScale
        %
        % INPUT:
        %   coordScale - (3 x 1 positive number)
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        assert(isnumeric(coordScale) && isreal(coordScale) && numel(coordScale) == 3 && all(coordScale > 0),...
            'trackable:trackable:set:coordScale',...
            'Property "coordScale" must be set to a 3 x 1 positive number.')
        coordScale = coordScale(:);
        
        trackableObj.coordScale = coordScale;
    end
    
    function set.coordOrientation(trackableObj,coordOrientation)  %#ok<*MCHV2>
        % Overloaded assignment operator function for the "coordOrientation" property.
        %
        % SYNTAX:
        %   trackableObj.coordOrientation = coordOrientation
        %
        % INPUT:
        %   coordOrientation - (1 x 1 quaternion)
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        assert(isa(coordOrientation,'quaternion') && numel(coordOrientation) == 1,...
            'trackable:trackable:set:coordOrientation',...
            'Property "coordOrientation" must be set to a 1 x 1 quaternion.')
        
        trackableObj.coordOrientation = coordOrientation;
    end
    
    function set.simulate(trackableObj,simulate)
        assert(islogical(simulate) && numel(simulate) == 1,...
            'trackable:trackable:set:simulate',...
            'Property "simulate" must be set to a 1 x 1 logical.')
        trackableObj.simulate = simulate;
    end
    
    function set.simTimeStep(trackableObj,simTimeStep)
        % Overloaded assignment operator function for the "simTimeStep" property.
        %
        % SYNTAX:
        %   trackableObj.simTimeStep = simTimeStep
        %
        % INPUT:
        %   simTimeStep - (1 x 1 positve number)
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        assert(isnumeric(simTimeStep) && isreal(simTimeStep) && numel(simTimeStep) == 1 && simTimeStep >= 0,...
            'trackable:trackable:set:simTimeStep',...
            'Property "simTimeStep" must be set to a 1 x 1 positive number.')
        
        trackableObj.simTimeStep = simTimeStep;
    end
    
    function time = get.time(trackableObj)
        time = trackableObj.timeRaw_ - trackableObj.timeOffset_;
    end

    function set.time(trackableObj,time) 
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
        
        if ~trackableObj.simulate
            trackableObj.update();
        end
        
        if isnan(trackableObj.timeRaw_)
            trackableObj.timeRaw_ = time;
        end
        trackableObj.timeOffset_ = trackableObj.timeRaw_ - time;
    end
    
    function position = get.position(trackableObj)
        position = trackableObj.positionRaw_ - trackableObj.positionOffset_;
    end
    
    function set.position(trackableObj,position) 
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

        if ~trackableObj.simulate
            trackableObj.update();
        end
        
        if any(isnan(trackableObj.positionRaw_))
            trackableObj.positionRaw_ = position;
        end
        trackableObj.positionOffset_ = trackableObj.positionRaw_ - position;
    end
    
    function x = get.x(trackableObj)
        x = trackableObj.position(1);
    end
    
    function set.x(trackableObj,x)
        trackableObj.position(1) = x;
    end
    
    function y = get.y(trackableObj)
        y = trackableObj.position(2);
    end
    
    function set.y(trackableObj,y)
        trackableObj.position(2) = y;
    end
    
    function z = get.z(trackableObj)
        z = trackableObj.position(3);
    end
    
    function set.z(trackableObj,z)
        trackableObj.position(3) = z;
    end
    
    function orientation = get.orientation(trackableObj)
        orientation = trackableObj.orientationRaw_ * trackableObj.orientationOffset_';
    end
    
    function set.orientation(trackableObj,orientation)
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
        assert((isa(orientation,'quaternion') && numel(orientation) == 1 ) || ...
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
        
        if ~trackableObj.simulate
            trackableObj.update();
        end
        
        if isnan(trackableObj.orientationRaw_)
            trackableObj.orientationRaw_ = orientation;
        end
        
        trackableObj.orientationOffset_ = orientation' * trackableObj.orientationRaw_;
        
    end
    
    function set.roll(trackableObj,roll)
        trackableObj.orientation.roll = roll;
    end
    
    function roll = get.roll(botObj)
        roll = botObj.orientation.roll;
    end
    
    function set.pitch(trackableObj,pitch)
        trackableObj.orientation.pitch = pitch;
    end
    
    function pitch = get.pitch(botObj)
        pitch = botObj.orientation.pitch;
    end
    
    function set.yaw(trackableObj,yaw)
        trackableObj.orientation.yaw = yaw;
    end
    
    function yaw = get.yaw(trackableObj)
        yaw = trackableObj.orientation.yaw;
    end

end
%-------------------------------------------------------------------------------

%% General Methods -------------------------------------------------------------
methods (Access = public)
    function result = init(trackableObj)
        % The "init" method initializes the trackable object
        %
        % SYNTAX:
        %   initResult = trackableObj.init()
        %
        % INPUTS:
        %   trackableObj - (1 x 1 trackable.trackable)
        %       An instance of the "trackable.trackable" class.
        %
        % OUTPUTS:
        %   result - (1 x 1 logical) 
        %       True if initialized.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
    
        result = true;
        if trackableObj.simulate
            trackableObj.time = 0;
            [pos,ori] = trackableObj.simUpdateHandle(trackableObj);
            if any(isnan(pos))
                pos = [0 0 0]';
            end
            if any(isnan(ori))
                ori = [1 0 0 0];
            end
            trackableObj.position = pos;
            trackableObj.orientation = ori;
        else
            trackableObj.ticID = tic;
            trackableObj.validate();
            if trackableObj.validServer
                trackableObj.update();
            end
            result = trackableObj.validServer;
        end
    end
    
    function validServer = setServerInfo(trackableObj,name,host,port)
        % The "setServerInfo" method updates the server information for
        % this trackable object.
        %
        % SYNTAX:
        %   validServer = trackableObj.setServerInfo(name,host,port)
        %
        % INPUTS:
        %   trackableObj - (1 x 1 trackable.trackable)
        %       An instance of the "trackable.trackable" class.
        %
        %   name - (string)
        %       Trackable name name.
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
        assert(~isempty(name) && ischar(name),...
            'trackable:trackable:setServerInfo:name',...
            'Input argument "name" must be a non-empty string.')
        
        assert(~isempty(host) && ischar(host),...
            'trackable:trackable:setServerInfo:host',...
            'Input argument "host" must be a non-empty string.')
        
        assert(~isempty(port) && ischar(port),...
            'trackable:trackable:setServerInfo:port',...
            'Input argument "port" must be a non-empty string.')
        
        trackableObj.name = name;
        trackableObj.host = host;
        trackableObj.port = port;
        trackableObj.validate();
        validServer = trackableObj.validServer;
    end
    
    function rotateGlobal(trackableObj,rotation)
        % The "rotateGlobal" method rotates the global referecen frame of
        % the trackable.
        %
        % SYNTAX:
        %   trackableObj.rotateGlobal(rotation)
        %
        % INPUTS:
        %   trackableObj - (1 x 1 trackable.trackable)
        %       An instance of the "trackable.trackable" class.
        %
        %   rotation - (1 x 1 quaternion or 4 x 1 real number with the norm equal to 1)
        %       Rotation quaternion.
        %
        % EXAMPLES:
        %   % Rotate 90 degrees around global frame Z-axis;
        %   trackableObj.rotateGlobal(quaternion([0 0 pi/2]));
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(2,2)
        
        % Check arguments for errors
        assert((isa(rotation,'quaternion') && numel(rotation) == 1 ) || ...
            (isnumeric(rotation) && isreal(rotation) && numel(rotation) == 4),...
            'trackable:rotateGlobal:rotation',...
            'Property "rotation" must be a 1 x 1 quaternion or a 4 x 1 real number.')
        
        if ~isa(rotation,'quaternion')
            rotation = rotation(:);
            if abs(norm(rotation) - 1) > .01;
                warning('trackable:rotateGlobal:rotation',...
                    'Property "rotation" norm is not very close to 1. (Norm = %.3f)',norm(rotation))
            end
            rotation = rotation / norm(rotation);
            rotation = quaternion(rotation);
        end
        
        trackableObj.orientationGlobalRotation_ = rotation' * trackableObj.orientationGlobalRotation_;
    end
    
    function [pos,ori] = simUpdate(trackableObj)
        % The "simUpdate" method updates the trackable position and
        % orientation when in simulation.
        %
        % SYNTAX:
        %   [pos,ori] = trackableObj.simUpdate()
        %
        % INPUTS:
        %   trackableObj - (1 x 1 trackable.trackable)
        %       An instance of the "trackable.trackable" class.
        %
        % OUTPUTS:
        %   pos - (3 x 1 number)
        %       Updated position.
        %
        %   ori - (1 x 1 quaternion or 4 x 1 real number with the norm equal to 1)
        %       Updated orientation.
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------

        % Check number of arguments
        narginchk(1,1)
        if any(isnan(trackableObj.position))
            pos = [0;0;0];
        else
            pos = trackableObj.position;
        end
        if isnan(trackableObj.orientation)
            ori = [1;0;0;0];
        else
            ori = trackableObj.orientation;
        end
    end
end
%-------------------------------------------------------------------------------

%% Methods in separte files ----------------------------------------------------
methods (Access = public)
    validate(trackableObj)
    update(trackableObj)
end
%-------------------------------------------------------------------------------
    
end
