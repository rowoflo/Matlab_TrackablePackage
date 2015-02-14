classdef diffdrive < trackable.trackable
% The "trackable.diffdrive" class is for differential drive robots.
%
% NOTES:
%   To get more information on this class type "doc trackable.diffdrive" into the
%   command window.
%
% NECESSARY FILES AND/OR PACKAGES:
%   @trackable, @quaternion
%
% SEE ALSO: TODO: Add see alsos
%    relatedFunction1 | relatedFunction2
%
% AUTHOR:
%    Rowland O'Flaherty (www.rowlandoflaherty.com)
%
% VERSION: 
%   Created 13-FEB-2015
%--------------------------------------------------------------------------

%% Properties -------------------------------------------------------------
properties (Access = public)
    simulate = false % (1 x 1 logical) If true the simulator is run instead of the real robot.
    teleop = false % (1 x 1 logical) If true diffdrive is controled by joystick.
    track = true % (1 x 1 logical) If true diffdrive updates trackable properties.
    motor = zeros(2,1) % (2 x 1 motorLimits(1)<=integer<=motorLimits(2)) Current motor values for motor 1 and 2.
    wheelRadius = 0.01 % (1 x 1 positive number) [meters] Radius of robot wheel.
    wheelBase = 0.1 % (1 x 1 positive number) [meters] Wheel base length of robot.
end

properties (GetAccess = public, SetAccess = private)
    sampleTime = .1 % (1 x 1 positive number) Sampling time for robot.
    motorLimits = [-100 100] % (1 x 2 integers) Minimum and maximum motor values.
end

properties (Access = public, Hidden = true)
    timeStep = .1 % (1 x 1 positive number) Time step for the simulator.
    zeroSize = .00001 % (1 x 1 positive number) Zero size values. If a number is less than this value it is rounded to zero.
end

properties (Access = private, Hidden = true)
    timeSim_ = 0 % (1 x 1 number) Raw time data
    positionSim_ = zeros(3,1) % (3 x 1 number) Raw position data
    orientationSim_ = quaternion() % (1 x 1 quaternion) Raw orientation data
end

%% Constructor ------------------------------------------------------------
methods
    function diffdriveObj = diffdrive(varargin)
        % Constructor function for the "diffdrive" class.
        %
        % SYNTAX: TODO: Add syntax
        %   diffdriveObj = trackable.diffdrive(arg1,[superClass arguments])
        %
        % INPUTS: TODO: Add inputs
        %   arg1 - (size type) [defaultArg1Value] 
        %       Sets the "diffdriveObj.prop1" property.
        %
        % OUTPUTS:
        %   diffdriveObj - (1 x 1 trackable.diffdrive object) 
        %       A new instance of the "trackable.diffdrive" class.
        %
        % NOTES:
        %
        %------------------------------------------------------------------
        
        % Check number of arguments TODO: Add number argument check
        narginchk(0,3)

        % Apply default values TODO: Add apply defaults
        % if nargin < 1, arg1 = 0; end

        % Check input arguments for errors TODO: Add error checks
        % assert(isnumeric(arg1) && isreal(arg1) && isequal(size(arg1),[1,1]),...
        %     'trackable:diffdrive:arg1',...
        %     'Input argument "arg1" must be a 1 x 1 real number.')
        
        % Initialize superclass
        diffdriveObj = diffdriveObj@trackable.trackable(varargin{:});
        
        % Assign properties
        diffdriveObj.time = 0;
        diffdriveObj.position = [0 0 0]';
        diffdriveObj.orientation = quaternion([0;0;1],0);
        
        diffdriveObj.tapeFlag = true;
    end
end
%--------------------------------------------------------------------------

%% Destructor -------------------------------------------------------------
% methods (Access = public)
%     function delete(diffdriveObj)
%         % Destructor function for the "diffdriveObj" class.
%         %
%         % SYNTAX:
%         %   delete(diffdriveObj)
%         %
%         % INPUTS:
%         %   diffdriveObj - (1 x 1 trackable.diffdrive)
%         %       An instance of the "trackable.diffdrive" class.
%         %
%         % NOTES:
%         %
%         %------------------------------------------------------------------
%         
%     end
% end
%--------------------------------------------------------------------------

%% Property Methods -------------------------------------------------------
methods
    function diffdriveObj = set.motor(diffdriveObj,motor)
        % Overloaded assignment operator function for the "motor" property.
        %
        % SYNTAX:
        %   diffdriveObj.motor = motor
        %
        % INPUT:
        %   motor - (2 x 1 motorLimits(1)<=integer<=motorLimits(2))
        %
        % NOTES:
        %
        %-----------------------------------------------------------------------
        %
        % *** Currently being checked in "setMoterValue" method ****
        % assert(isnumeric(motor) && isreal(motor) && numel(motor) == 2 && ...
        %     all(mod(motor,1) == 0) && all(motor >= 0) && all(motor <= 255),...
        %     'diffdrive:set:motor',...
        %     'Property "motor" must be set to a 2 x 1 integer between 0 and 255.')
        % motor = motor(:);

        diffdriveObj.motor = diffdriveObj.setMoterValue(motor);
    end
    
%     function diffdriveObj = set.prop1(diffdriveObj,prop1)
%         % Overloaded assignment operator function for the "prop1" property.
%         %
%         % SYNTAX:
%         %   diffdriveObj.prop1 = prop1
%         %
%         % INPUT:
%         %   prop1 - (1 x 1 real number)
%         %
%         % NOTES:
%         %
%         %------------------------------------------------------------------
%         assert(isnumeric(prop1) && isreal(prop1) && isequal(size(prop1),[1,1]),...
%             'trackable:diffdrive:set:prop1',...
%             'Property "prop1" must be set to a 1 x 1 real number.')
% 
%         diffdriveObj.prop1 = prop1;
%     end
%     
%     function prop1 = get.prop1(diffdriveObj)
%         % Overloaded query operator function for the "prop1" property.
%         %
%         % SYNTAX:
%         %	  prop1 = diffdriveObj.prop1
%         %
%         % OUTPUT:
%         %   prop1 - (1 x 1 real number)
%         %
%         % NOTES:
%         %
%         %------------------------------------------------------------------
% 
%         prop1 = diffdriveObj.prop1;
%     end
end
%--------------------------------------------------------------------------

%% General Methods -------------------------------------------------------------
% methods (Access = public)
%     function diffdriveObj = method_name(diffdriveObj,arg1)
%         % The "method_name" method ...
%         %
%         % SYNTAX:
%         %   diffdriveObj = diffdriveObj.method_name(arg1)
%         %
%         % INPUTS:
%         %   diffdriveObj - (1 x 1 trackable.diffdrive)
%         %       An instance of the "trackable.diffdrive" class.
%         %
%         %   arg1 - (size type) [defaultArgumentValue] 
%         %       Description.
%         %
%         % OUTPUTS:
%         %   diffdriveObj - (1 x 1 trackable.diffdrive)
%         %       An instance of the "trackable.diffdrive" class ... 
%         %
%         % NOTES:
%         %
%         %-----------------------------------------------------------------------
% 
%         % Check number of arguments
%         narginchk(1,2)
%         
%         % Apply default values
%         if nargin < 2, arg1 = 0; end
%         
%         % Check arguments for errors
%         assert(isnumeric(arg1) && isreal(arg1) && isequal(size(arg1),[?,?]),...
%             'trackable:diffdrive:method_name:arg1',...
%             'Input argument "arg1" must be a ? x ? matrix of real numbers.')
%         
%     end
%     
% end
%-------------------------------------------------------------------------------


%% Methods in separte files -----------------------------------------------
methods (Access = public)
    update(diffdriveObj)
    
    motorValues = teleoperation(diffdriveObj)
end
methods (Access = private)
    motorValues = setMoterValue(diffdriveObj,motorValues)
    [time,pos,ori] = simulator(diffdriveObj,timeStep,time,pos,ori)
end
%--------------------------------------------------------------------------
    
end
