clear, clc, close all

% figure meta
meta.figSize = [100,100,1000,500]; % first two values are location, second two are size
meta.fontSize.big   = 15;
meta.fontSize.small = 10;
meta.pltCols = {'r','b'};

% data meta
meta.variableNames = {'location','season','AxisRatioNormed','EllipseAngle','EllipseArea'};
meta.seasonNames = {'Summer','Autumn','Winter','Spring'};
meta.locationNames = {'Tromsø','Oslo'};
meta.aboveBelowNames = {'below','above'};

addpath(genpath('arc_ImageAnalysis')); % TODO Remove dependencies
addpath(genpath('imageanalysis'));

%% Data and save locations

dataDir = ['.',filesep,'data',filesep,'processed'];
saveLocation = ['.',filesep,'figs',filesep];

%% Load preprocessed data

data.GoPro = readmatrix([dataDir,filesep,'GoPro_sub.csv']); % generated in data/processed/scripts/preProcessGoPro.m

data.NL_mb = readmatrix([dataDir,filesep,'nanoLambda',filesep,'NL_sub.csv']); % generated in data/processed/scripts/preProcessNL.m

%data.HS = load(paths.HSProcessedData,'d'); 
%data.PP = load(paths.PPProcessedData);

%% Compute ellipse

[LogAxisRatioNCE, AxisRatioNormed, ~, ~, EllipseAngleUnnormed, ~, SemiMajorLength, SemiMinorLength] = ...
    GetAxisRatio(data.NL_mb(:,3),data.NL_mb(:,4));

EllipseArea = pi * SemiMajorLength * SemiMinorLength;

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

%% WIP

when = readtable(['data',filesep,'processed',filesep,'nanoLambda',filesep,'NL_when.csv']);

for location = [0,1]

    t2 = t(data.NL_mb(:,1) == 1,:).Var1;
    [Y,E] = discretize(t2,"hour");
    uniqueHourIndices = unique(Y);

    for i = 1:length(uniqueHourIndices)
        try
            [LogAxisRatioNCE(i), AxisRatioNormed(i), ~, ~, EllipseAngleUnnormed(i), ~, SemiMajorLength(i), SemiMinorLength(i)] = ...
                GetAxisRatio(data.NL_mb(Y == uniqueHourIndices(i),3),data.NL_mb(Y == uniqueHourIndices(i),4));
            EllipseArea(i) = pi * SemiMajorLength(i) * SemiMinorLength(i);
        catch
            disp(i)
            LogAxisRatioNCE(i) = NaN;
            AxisRatioNormed(i) = NaN;
            EllipseAngleUnnormed(i) = NaN;
            SemiMajorLength(i) = NaN;
            SemiMinorLength(i) = NaN;
            EllipseArea(i) = NaN;
        end
        location_(i) = unique(data.NL_mb(Y == uniqueHourIndices(i),1));
        season(i) = unique(data.NL_mb(Y == uniqueHourIndices(i),2));
    end
end

%% Plots

for i = 3:5
    arc_ellipseScatter_splitByLocationAndSeason(data.GoPro,meta,i)
    arc_saveFig([saveLocation,'ellipseScatter','_',meta.variableNames{i}],meta)
end

