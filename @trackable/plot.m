function plot(trackableObj)
% The "plot" method ... TODO: Add description
%
% SYNTAX: TODO: Add syntax
%   trackableObj = trackableObj.plot(arg1)
%
% INPUTS: TODO: Add inputs
%   trackableObj - (1 x 1 trackable.trackable)
%       An instance of the "trackable.trackable" class.
%
%   arg1 - (size type) [defaultArgumentValue] 
%       Description.
%
% OUTPUTS: TODO: Add outputs
%   trackableObj - (1 x 1 trackable.trackable)
%       An instance of the "trackable.trackable" class ... ???.
%
% NOTES:
%
% NECESSARY FILES AND/OR PACKAGES: TODO: Add necessary files
%   +trackable, someFile.m
%
% SEE ALSO: TODO: Add see alsos
%    relatedFunction1 | relatedFunction2
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
%     'trackable:trackable:plot:trackableObj',...
%     'Input argument "trackableObj" must be a 1 x 1 "trackable.trackable" object.')
%
% assert(isnumeric(arg1) && isreal(arg1) && isequal(size(arg1),[?,?]),...
%     'trackable:trackable:plot:arg1',...
%     'Input argument "arg1" must be a ? x ? matrix of real numbers.')

%% Parameters
plotSize = 8;
plotPath = true;

%% Variables
t = trackableObj.time;
H = trackableObj.transform;

%% Initialize
% Create Figure
if isempty(trackableObj.figHandle) || ~ishghandle(trackableObj.figHandle) || isempty(trackableObj.axisHandle) || ~ishghandle(trackableObj.axisHandle)
    if isempty(trackableObj.figHandle)
        trackableObj.figHandle = figure;
    else
        figure(trackableObj.figHandle);
    end
%     if ~isempty(trackableObj.sketchFigureProperties)
%         set(trackableObj.figHandle,trackableObj.sketchFigureProperties{:});
%     end
end

% Create Axis
if isempty(trackableObj.axisHandle) || ~ishghandle(trackableObj.axisHandle)
    % Create Axis
    figure(trackableObj.figHandle);
    trackableObj.axisHandle = gca;
    cla(trackableObj.axisHandle)
    set(trackableObj.axisHandle,'DrawMode','normal')
%     set(trackableObj.axisHandle,'NextPlot','add')
    axis equal
%     if ~isempty(trackableObj.sketchAxisProperties)
%         set(trackableObj.axisHandle,trackableObj.sketchAxisProperties{:});
%     end
end
title(trackableObj.axisHandle,[trackableObj.device ' (Time = ' num2str(t,'%.1f') ')'])

%% Plot

% Initialial plot
if isempty(trackableObj.graphicsHandles) || all(~ishghandle(trackableObj.graphicsHandles))
    % Set properties
    xlim(trackableObj.axisHandle,1/2*[-plotSize,plotSize])
    ylim(trackableObj.axisHandle,1/2*[-plotSize,plotSize])
    zlim(trackableObj.axisHandle,[0,plotSize])
    grid(trackableObj.axisHandle,'on')
    
    % Create static objects
    
end

% Update plot
if isempty(trackableObj.graphicsHandles) || ...
        any(~ismember(trackableObj.graphicsHandles,get(trackableObj.axisHandle,'Children')))
    
    % Create dynamic objects
    trackableObj.graphicsHandles(1) = line('Parent',trackableObj.axisHandle,...
        'XData',[H(1,4) H(1,1)+H(1,4)],...
        'YData',[H(2,4) H(2,1)+H(2,4)],...
        'ZData',[H(3,4) H(3,1)+H(3,4)],...
        'Color','b',...
        'LineWidth',2);
    
    trackableObj.graphicsHandles(2) = line('Parent',trackableObj.axisHandle,...
        'XData',[H(1,4) H(1,2)+H(1,4)],...
        'YData',[H(2,4) H(2,2)+H(2,4)],...
        'ZData',[H(3,4) H(3,2)+H(3,4)],...
        'Color','g',...
        'LineWidth',2);
    
    trackableObj.graphicsHandles(3) = line('Parent',trackableObj.axisHandle,...
        'XData',[H(1,4) H(1,3)+H(1,4)],...
        'YData',[H(2,4) H(2,3)+H(2,4)],...
        'ZData',[H(3,4) H(3,3)+H(3,4)],...
        'Color','r',...
        'LineWidth',2);
    
    if plotPath
    trackableObj.graphicsHandles(4) = line('Parent',trackableObj.axisHandle,...
        'XData',trackableObj.positionTape(1,:),...
        'YData',trackableObj.positionTape(2,:),...
        'ZData',trackableObj.positionTape(3,:),...
        'Color','m',...
        'LineStyle',':',...
        'LineWidth',1);
    end
    
else
    
    % Update dynamic objects
    set(trackableObj.graphicsHandles(1),...
        'XData',[H(1,4) H(1,1)+H(1,4)],...
        'YData',[H(2,4) H(2,1)+H(2,4)],...
        'ZData',[H(3,4) H(3,1)+H(3,4)]);
    
    set(trackableObj.graphicsHandles(2),...
        'XData',[H(1,4) H(1,2)+H(1,4)],...
        'YData',[H(2,4) H(2,2)+H(2,4)],...
        'ZData',[H(3,4) H(3,2)+H(3,4)]);
    
    set(trackableObj.graphicsHandles(3),...
        'XData',[H(1,4) H(1,3)+H(1,4)],...
        'YData',[H(2,4) H(2,3)+H(2,4)],...
        'ZData',[H(3,4) H(3,3)+H(3,4)]);
    
    if plotPath
    set(trackableObj.graphicsHandles(4),...
        'XData',trackableObj.positionTape(1,:),...
        'YData',trackableObj.positionTape(2,:),...
        'ZData',trackableObj.positionTape(3,:));
    end
    
    % Recenter plot
    XLim = get(trackableObj.axisHandle,'XLim');
    YLim = get(trackableObj.axisHandle,'YLim');
    if H(1,4) <= XLim(1) + 1 || H(1,4) >= XLim(2) - 1 || ...
        H(2,4) <= YLim(1) + 1 || H(2,4) >= YLim(2) - 1
    
        set(trackableObj.axisHandle,...
            'XLim',H(1,4)+1/2*[-plotSize,plotSize],...
            'YLim',H(2,4)+1/2*[-plotSize,plotSize]);
    end
        

end
