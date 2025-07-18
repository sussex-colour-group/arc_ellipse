% Process data into the format needed

clc, clear, close all

%% Raw data location:

% TBC, TODO
% (wider project link: https://osf.io/z576y/)

%% Manual steps required:

% - Download data
% - Unzip it
% - Place it in the data/raw/hyperspectral directory (or elsewhere)

%% define paths

repoHomeDir = ['..',filesep,'..',filesep,'..',filesep];
addpath(repoHomeDir);
addpath([repoHomeDir,'imageanalysis',filesep]);
addpath([repoHomeDir,'hyperspectralAnalysis',filesep]);

%% Preprocess data

prompt = ['Are you sure you want to run this chunk?', newline...
    'It requires quite a lot of time and computational resources ', newline];
response = input(prompt,"s");

if strcmp(response,'y')
    
    AnalyseHyperspectral(localPaths.HSRawData,localPaths.HSLMSImages)

end

%% Compute ellipse stats

LMSimDir = '~/cisc1/projects/colour_arctic/hyperspectralOutputs';
d = dir([LMSimDir,filesep,'*.mat']);

parfor i = 1:size(d,1)

    t = load([d(i).folder,filesep,d(i).name],'LLMImage','SLMImage');

    [LogAxisRatioNCE(i), AxisRatioNormed(i), ~, ~, EllipseAngleUnnormed(i), ~, SemiMajorLength(i), SemiMinorLength(i)] = ...
        GetAxisRatio(t.LLMImage,t.SLMImage);
    EllipseArea(i) = pi * SemiMajorLength(i) * SemiMinorLength(i);
    center(i,:) = [mean(t.LLMImage(:),"omitnan"),mean(t.SLMImage(:),"omitnan")];
end

%%

% get location variable

d = dir('/home/danny/cisc2/projects/colour_arctic/data/Norway Hyperspectral/Hyperspectral/**/*.raw');


%% Save output
writetable([struct2table(d),table(LogAxisRatioNCE','VariableNames',"LogAxisRatio"),... % I should've done this in the loop above...
    table(AxisRatioNormed','VariableNames',"AxisRatioNormed"),...
    table(EllipseAngleUnnormed','VariableNames',"EllipseAngleUnnormed"),...
    table(SemiMajorLength','VariableNames',"SemiMajorLength"),...
    table(SemiMinorLength','VariableNames',"SemiMinorLength"),...
    table(EllipseArea','VariableNames',"EllipseArea"),...
    table(center(:,1),'VariableNames',"center_LLM"),...
    table(center(:,2),'VariableNames',"center_SLM")],...
    ['..',filesep,'hyperspectral',filesep,'HS.csv'])

%% Remove duplicates from HS data

if false
    d = dir(localPaths.HSImagePreviews);
    fnames = {d(~[d.isdir]).name}';

    writecell(fnames,'deDupeHS.csv');

    % TODO
    % manually go through all the images and write whether they are to be
    % included or not (1 to include, 0 to exclude, in a second column)
end

%%




