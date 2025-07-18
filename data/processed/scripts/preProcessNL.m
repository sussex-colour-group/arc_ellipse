% Process data into the format needed

clc, clear, close all

%% Raw data location:

% https://osf.io/z576y/files/osfstorage/6838c51c33f409690b539714 
% (wider project link: https://osf.io/z576y/)

%% Manual steps required:

% - Download data
% - Unzip it
% - Place it in the data/raw/nanoLambda directory 
% (or wherever you like if you're happy to modify the next line)

%% define paths

dataDir = ['..',filesep,'..',filesep,'raw',filesep,'nanoLambda'];
saveDir = ['..',filesep,'..',filesep,'processed',filesep,'nanoLambda'];

% add scripts to the path
addpath(genpath(['..',filesep,'..',filesep,'..',filesep]));

%% Preprocess data

prompt = ['Are you sure you want to run this chunk?', newline...
    'It requires quite a lot of time and computational resources ', newline];
response = input(prompt,"s");

if strcmp(response,'y')

    % the list of paths (within dataDir) to process
    paths = {['TROMSO',filesep,'Autumn'],['TROMSO',filesep,'Spring'],['TROMSO',filesep,'Summer 21'],['TROMSO',filesep,'SUMMER 22'],['TROMSO',filesep,'Winter 21'],['TROMSO',filesep,'Winter 22'],...
        ['OSLO',filesep,'Autumn 21'],['OSLO',filesep,'Spring 22'],['OSLO',filesep,'Summer 21'],['OSLO',filesep,'Summer 22'],['OSLO',filesep,'Winter 21 og 22'],['OSLO',filesep,'WINTER 22']};

    % extract the data from the original csvs and package it into MATLAB files
    % warning: this takes quite a long time to run (~10 mins)
    arc_NLextract(dataDir,saveDir,paths)

    % concatenate the MATLAB files from above into a pair of big csv files
    % (one for spectra, and one for everything else)
    % warning: this takes quite a long time to run (~10 mins)
    NLconcat(saveDir,saveDir)

end

%% Read in preprocessed data

concatNLdata = readtable([saveDir,filesep,'concatNLdata.csv']);
concatSpecArray = readmatrix([saveDir,filesep,'concatSpecArray.csv']);

%% Remove dodgy sensor data

dodgySensor = 'C3:76:CE:37:CF:28';

filterOut = zeros(size(concatNLdata,1),1);
for j = 1:size(concatNLdata,1)
    filterOut(j) = isequal(concatNLdata(j,:).deviceAddress,{dodgySensor});
end

concatNLdata = concatNLdata(~filterOut,:);
concatSpecArray = concatSpecArray([true;~filterOut],:);

%% Compute MB chromaticities

addpath(genpath(['..',filesep,'..',filesep,'..',filesep,'arc_ImageAnalysis']));

MBarray = NLspd2MB(concatSpecArray);

%% Package neatly

% 'location','season', MBarray

tidyData = NaN(size(concatNLdata,1),5);

tidyData(:,1) = contains(concatNLdata.file,'OSLO','IgnoreCase',true);

% seasonNames = {'Summer','Autumn','Winter','Spring'};
tidyData(contains(concatNLdata.file,'Summer','IgnoreCase',true),2) = 1;
tidyData(contains(concatNLdata.file,'Autumn','IgnoreCase',true),2) = 2;
tidyData(contains(concatNLdata.file,'Winter','IgnoreCase',true),2) = 3;
tidyData(contains(concatNLdata.file,'Spring','IgnoreCase',true),2) = 4;

tidyData(:,3:5) = MBarray;

%% Split nanolambda data into hourly chunks and compute ellipse parameters

clc

minN = 50; % miniumum number of measurements within a chunk (otherwise return NaN)

for location = [0,1]

    when_locationSplit{location+1}.when       = concatNLdata.when(tidyData(:,1) == location,1);
    when_locationSplit{location+1}.dataSubset =          tidyData(tidyData(:,1) == location,:);

    when_locationSplit{location+1}.hourBinIndices = discretize(when_locationSplit{location+1}.when,"hour");
    when_locationSplit{location+1}.uniqueHourBinIndices = unique(when_locationSplit{location+1}.hourBinIndices);

    for i = 1:length(when_locationSplit{location+1}.uniqueHourBinIndices)
        nMeasPerHour(i) = length(when_locationSplit{location+1}.dataSubset(when_locationSplit{location+1}.hourBinIndices == when_locationSplit{location+1}.uniqueHourBinIndices(i),3));
        try
            if nMeasPerHour(i)>minN
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

%%

rng(42);
n = 30;
randomIndices = when_locationSplit{1,1}.uniqueHourBinIndices(randi(size(when_locationSplit{1,1}.uniqueHourBinIndices,1),[n,1]));

figure, hold on
tiledlayout(3,10);

for i = 1:length(randomIndices)
    x = when_locationSplit{1,1}.dataSubset(when_locationSplit{1,1}.hourBinIndices == randomIndices(i),3);
    y = when_locationSplit{1,1}.dataSubset(when_locationSplit{1,1}.hourBinIndices == randomIndices(i),4);

    meta.figType = "grey";
    % meta.edges = {linspace(0.66,0.82,40) linspace(0,2,40)};
    meta.edges = {linspace(0.55,0.9,40) linspace(0,4,40)};
    specLocus = false; % for some reason having this set to true this makes everything run _very_ slow. TODO investigate
    nexttile
    arc_2Dhist(x,y,meta,specLocus);

    center(i,:) = [mean(x,"omitnan"),mean(y,"omitnan")];
    % EllipseArea(im) = pi * SemiMajorLength(im) * SemiMinorLength(im);

    indind = find(when_locationSplit{1,1}.uniqueHourBinIndices == randomIndices(i));
    try
        drawellipse(gca,'SemiAxes',[SemiMajorLength{1,1}(indind),SemiMinorLength{1,1}(indind)],...
            'Center',center(i,:),...
            'RotationAngle',360-EllipseAngleUnnormed{1,1}(indind),...
            'FaceAlpha',0);
        % colormap('turbo')
    catch e
        disp(i)
        disp(e)
    end

end

%%

tidyData = cat(2,tidyData(:,[1,2]),[when_locationSplit{1}.dataSubset(:,[6,8,9]); when_locationSplit{2}.dataSubset(:,[6,8,9])]);

writematrix(tidyData,[saveDir,filesep,'NL_sub.csv']); % this is 30mb, and quite redundant, so ideally we would pack it (store only one set of values per unique hour index) but I don't have time for this right now

