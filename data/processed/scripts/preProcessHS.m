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

drawFigs = false; % parfor doesn't recognise this, so it needs commenting out as well unfortunately
if drawFigs
    rng(1) % if we're randomly selecting a subset, make it reproducible
    nIm = 6;
    figure, hold on
    tiledlayout(2,nIm);
end

for i = 1:size(d,1) %randi(size(d,1),[1,nIm])
    disp(i)

    t = load([d(i).folder,filesep,d(i).name],'LLMImage','SLMImage');

    [LogAxisRatioNCE(i), AxisRatioNormed(i), ~, ~, EllipseAngleUnnormed(i), ~, SemiMajorLength(i), SemiMinorLength(i)] = ...
        GetAxisRatio(t.LLMImage,t.SLMImage);
    EllipseArea(i) = pi * SemiMajorLength(i) * SemiMinorLength(i);
    center(i,:) = [mean(t.LLMImage(:),"omitnan"),mean(t.SLMImage(:),"omitnan")];

    % if drawFigs
    %     nexttile
    %     imshow(imread([LMSimDir,filesep,d(i).name(1:end-10),'.png']))
    % 
    %     nexttile
    %     meta.figType = "grey";
    %     meta.edges = {linspace(0.66,0.82,40) linspace(0,2,40)};
    %     specLocus = false; % for some reason having this set to true this makes everything run _very_ slow. TODO investigate
    %     arc_2Dhist(t.LLMImage(:),t.SLMImage(:),meta,specLocus);
    %     drawellipse(gca,'SemiAxes',[SemiMajorLength(i),SemiMinorLength(i)],...
    %         'Center',center(i,:),...
    %         'RotationAngle',360-EllipseAngleUnnormed(i),...
    %         'FaceAlpha',0);
    % end
end

%%
writetable()

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




