clear, clc, close all

% figure meta
meta.figSize = [100,100,1000,500]; % first two values are location, second two are size
meta.fontSize.big   = 15;
meta.fontSize.small = 10;
meta.pltCols = {'r','b'};

% data meta
meta.variableNames = {'location','season','LogAxisRatio','EllipseAngle','EllipseArea'};
meta.seasonNames = {'Summer','Autumn','Winter','Spring'};
meta.locationNames = {'Tromsø','Oslo'};
meta.aboveBelowNames = {'below','above'};

addpath(genpath('arc_ImageAnalysis')); % TODO Remove dependencies
addpath(genpath('imageanalysis'));

%% Data and save locations

dataDir = ['.',filesep,'data',filesep,'processed'];
saveLocation = ['.',filesep,'figs',filesep];

%% Load preprocessed data

data.GoPro = readmatrix([dataDir,filesep,'GoPro',filesep,'GoPro_sub.csv']); % generated in data/processed/scripts/preProcessGoPro.m

data.NL = readmatrix([dataDir,filesep,'nanoLambda',filesep,'NL_sub.csv']); % generated in data/processed/scripts/preProcessNL.m
data.NL_denoised = removeNLdarknoise(data.NL,10);

data.HS = readtable([dataDir,filesep,'hyperspectral',filesep,'HS.csv']); % generated in data/processed/scripts/preProcessHS.m
data.HS = transformHSData(data.HS);


%% Plots

% Go Pro
for i = 3:5
    arc_ellipseScatter_splitByLocationAndSeason(data.GoPro,meta,i)
    title('GoPro')
    arc_saveFig([saveLocation,'ellipseScatter','_GoPro_',meta.variableNames{i}],meta)
end

% Nanolambda
for i = 3:5
    arc_ellipseScatter_splitByLocationAndSeason(data.NL,meta,i)
    title('NL')
    arc_saveFig([saveLocation,'ellipseScatter','_NL_',meta.variableNames{i}],meta)
end

% Hyperspectral
for i = 3:5
    arc_ellipseScatter_splitByLocationAndSeason(data.HS,meta,i)
    title('HS')
    arc_saveFig([saveLocation,'ellipseScatter','_HS_',meta.variableNames{i}],meta)
end








