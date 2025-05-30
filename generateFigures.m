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

%% Data and save locations

dataDir = ['.',filesep,'data',filesep,'processed'];
saveLocation = ['.',filesep,'figs',filesep];

%% Load preprocessed data

data.GoPro = readmatrix([dataDir,filesep,'GoPro_sub.csv']); % generated in data/processed/scripts/preProcessGoPro.m

data.NL_mb = readmatrix([dataDir,filesep,'nanoLambda',filesep,'NL_sub.csv']); % generated in data/processed/scripts/preProcessNL.m

%data.HS = load(paths.HSProcessedData,'d'); 
%data.PP = load(paths.PPProcessedData);

%%

[LogAxisRatioNCE, AxisRatioNormed, ~, ~, EllipseAngleUnnormed, ~, SemiMajorLength, SemiMinorLength] = ...
    GetAxisRatio(data.NL_mb(:,3),data.NL_mb(:,3));

EllipseArea = pi * SemiMajorLength * SemiMinorLength;

% TODO Something is not working here

figure,
scatter(data.NL_mb(:,3),data.NL_mb(:,4))

%%

% Visualise ellipse

%% Plots

for i = 3:5
    arc_ellipseScatter_splitByLocationAndSeason(data.GoPro,meta,i)
    arc_saveFig([saveLocation,'ellipseScatter','_',meta.variableNames{i}],meta)
end

