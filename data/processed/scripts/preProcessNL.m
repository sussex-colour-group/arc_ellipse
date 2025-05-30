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

% add the nanolambda scripts to the path
addpath(['..',filesep,'..',filesep,'..',filesep,'Sussex_nanoLambda',filesep]);

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
    arc_NLconcat(saveDir,saveDir)

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

writematrix(tidyData,[saveDir,filesep,'NL_sub.csv']);