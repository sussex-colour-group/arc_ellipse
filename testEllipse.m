% Do some tests related to ellipse computation

%% Compute ellipse

% [LogAxisRatioNCE, AxisRatioNormed, ~, ~, EllipseAngleUnnormed, ~, SemiMajorLength, SemiMinorLength] = ...
%     GetAxisRatio(data.NL_mb(:,3),data.NL_mb(:,4));
% 
% EllipseArea = pi * SemiMajorLength * SemiMinorLength;

%% Visualise ellipse

% meta.edges = {linspace(0.66,0.82,40) linspace(0,2,40)}; % standard for white paper
meta.edges = {linspace(0.55,0.9,40) linspace(0,4,40)}; % wider, used in white paper SI

figure, hold on
% scatter(data.NL_mb(1:1000:end,3),data.NL_mb(1:1000:end,4),'k.')
histogram2(data.NL_mb(:,3),data.NL_mb(:,4),...
    'XBinedges',meta.edges{1,1},'YBinedges',meta.edges{1,2},...
    'DisplayStyle','tile','ShowEmptyBins','on','EdgeColor','none');
colormap('gray')

% PlotStandardDeviationEllipseParametric
StandardDeviations = 1;
unusedVariable = 'bla';
PlotStandardDeviationEllipseParametric(data.NL_mb(:,3),data.NL_mb(:,4),...
    StandardDeviations,...
    unusedVariable,3,[0.5,0.5,0.5]);

% drawellipse_custom
drawellipse_custom([SemiMinorLength;SemiMajorLength],... 
    [mean(data.NL_mb(:,3)),mean(data.NL_mb(:,4))],...
    EllipseAngleUnnormed,...
    5,[1,0.5,0.5]);

% drawellipse_custom([SemiMinorLength*1.5096;SemiMajorLength*1.5096],... % 1.5096 just a value I've eyeballed to try and make them match
%     [mean(data.NL_mb(:,3)),mean(data.NL_mb(:,4))],...
%     EllipseAngleUnnormed,...
%     3,[1,0.5,0.5]);

% drawellipse (default MATLAB)
drawellipse(gca,'SemiAxes',[SemiMajorLength,SemiMinorLength],...
    'Center',[mean(data.NL_mb(:,3)),mean(data.NL_mb(:,4))],...
    'RotationAngle',360-EllipseAngleUnnormed);

