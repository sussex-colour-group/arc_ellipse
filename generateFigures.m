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

data.NL_mb = readmatrix([dataDir,filesep,'nanoLambda',filesep,'NL_sub.csv']); % generated in data/processed/scripts/preProcessNL.m
data.NL_denoised = removeNLdarknoise(data.NL_mb,10);

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

%% Split nanolambda data into hourly chunks

when = readtable(['data',filesep,'processed',filesep,'nanoLambda',filesep,'NL_when.csv']);

%%

clear LogAxisRatioNCE AxisRatioNormed EllipseAngleUnnormed SemiMajorLength SemiMinorLength EllipseArea
clear Y E uniqueHourIndices
clear when_locationSplit

for location = [0,1]

    when_locationSplit{location+1}.when       =       when(data.NL_mb(:,1) == location,1).Var1;
    when_locationSplit{location+1}.dataSubset = data.NL_mb(data.NL_mb(:,1) == location,:);

    when_locationSplit{location+1}.hourBinIndices = discretize(when_locationSplit{location+1}.when,"hour");
    when_locationSplit{location+1}.uniqueHourBinIndices = unique(when_locationSplit{location+1}.hourBinIndices);

    for i = 1:length(when_locationSplit{location+1}.uniqueHourBinIndices)
        nMeasPerHour(i) = length(when_locationSplit{location+1}.dataSubset(when_locationSplit{location+1}.hourBinIndices == when_locationSplit{location+1}.uniqueHourBinIndices(i),3));
        try
            if nMeasPerHour(i)>50
            [LogAxisRatioNCE{location+1}(i),...
                AxisRatioNormed{location+1}(i),...
                ~,...
                ~,...
                EllipseAngleUnnormed{location+1}(i),...
                ~,...
                SemiMajorLength{location+1}(i),...
                SemiMinorLength{location+1}(i)] = ...
                GetAxisRatio(...
                when_locationSplit{location+1}.dataSubset(when_locationSplit{location+1}.hourBinIndices == when_locationSplit{location+1}.uniqueHourBinIndices(i),3),...
                when_locationSplit{location+1}.dataSubset(when_locationSplit{location+1}.hourBinIndices == when_locationSplit{location+1}.uniqueHourBinIndices(i),4));

            EllipseArea{location+1}(i) = pi * SemiMajorLength{location+1}(i) * SemiMinorLength{location+1}(i);
            else
                error('bla'); % this is just to pass it onto the catch statement - there's probably a "correct" way to do this
            end
        catch %e
            % disp(e)
            disp("Excluding: ")
            disp([num2str(location), '-',num2str(i)])
            disp(numel(when_locationSplit{location+1}.dataSubset(when_locationSplit{location+1}.hourBinIndices == when_locationSplit{location+1}.uniqueHourBinIndices(i),3)))
            
            LogAxisRatioNCE{location+1}(i) = NaN;
            AxisRatioNormed{location+1}(i) = NaN;
            EllipseAngleUnnormed{location+1}(i) = NaN;
            SemiMajorLength{location+1}(i) = NaN;
            SemiMinorLength{location+1}(i) = NaN;
            EllipseArea{location+1}(i) = NaN;
        end

        when_locationSplit{location+1}.dataSubset(when_locationSplit{location+1}.hourBinIndices == when_locationSplit{location+1}.uniqueHourBinIndices(i),6) = LogAxisRatioNCE{location+1}(i);
        when_locationSplit{location+1}.dataSubset(when_locationSplit{location+1}.hourBinIndices == when_locationSplit{location+1}.uniqueHourBinIndices(i),7) = AxisRatioNormed{location+1}(i);
        when_locationSplit{location+1}.dataSubset(when_locationSplit{location+1}.hourBinIndices == when_locationSplit{location+1}.uniqueHourBinIndices(i),8) = EllipseAngleUnnormed{location+1}(i);
        when_locationSplit{location+1}.dataSubset(when_locationSplit{location+1}.hourBinIndices == when_locationSplit{location+1}.uniqueHourBinIndices(i),9) = SemiMajorLength{location+1}(i);
        when_locationSplit{location+1}.dataSubset(when_locationSplit{location+1}.hourBinIndices == when_locationSplit{location+1}.uniqueHourBinIndices(i),10) = SemiMinorLength{location+1}(i);
        when_locationSplit{location+1}.dataSubset(when_locationSplit{location+1}.hourBinIndices == when_locationSplit{location+1}.uniqueHourBinIndices(i),11) = EllipseArea{location+1}(i);
    end
end

% figure, histogram(nMeasPerHour)

when_out = [when_locationSplit{1}.dataSubset(:,[1,2,6,8,9]); when_locationSplit{2}.dataSubset(:,[1,2,6,8,9])]; % TODO Replace data.NL with this output once I'm happy with it

%% Plots

% arc_ellipse\data\processed\scripts\preProcessGoPro.m
% mat(i,3) = t.AxisRatioNormed(i);
% mat(i,4) = t.EllipseAngle(i);
% mat(i,5) = t.EllipseArea(i);

% Go Pro
for i = 3:5
    arc_ellipseScatter_splitByLocationAndSeason(data.GoPro,meta,i)
    title('GoPro')
    arc_saveFig([saveLocation,'ellipseScatter','_GoPro_',meta.variableNames{i}],meta)
end

%%
% Nanolambda

for i = 3:5
    arc_ellipseScatter_splitByLocationAndSeason(when_out,meta,i)
    title('NL')
    arc_saveFig([saveLocation,'ellipseScatter','_NL_',meta.variableNames{i}],meta)
end




