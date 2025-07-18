%% Plot ellipses over images

% plots 2Dhist and ellipse (and image, in the case of GoPro and
% hyperspectral image)


%% Go Pro

clc, clear, close all

addpath(genpath('imageanalysis'));

load('/home/danny/LANShareDownloads/arc_GoProStats_V1.mat','fileList');

% t = readtable(['data',filesep,'processed',filesep,'GoPro',filesep,'GoPro.csv']);

rng(2);
nIm = 6;

for i = 1:size(fileList,1) % extract the V1 field (there _must_ be an easier and more sensible way than this, but `[fileList(i).V1]` doesn't work because a lot of the values are empty, and a simple `for` doesn't work for the same reason
    try
        V1(i) = fileList(i).V1;
    catch
        V1(i) = 0;
    end
end
V1ind = find(V1);
randomImageIndices = V1ind(randi(size(V1ind),[nIm,1]));

RGBs=SelectRGBs('DC13102022');
LMS=SelectConeFundamentals('StockmanMacleodJohnson');
[RGB2LMS,LMS2RGB]=RGBToLMS(LMS,RGBs,0);

satVal = 15000; % this value chosen based on gae_satPixelount analysis, it works on the RGB values, not the calibrated saturation as it is about saturated sensor
drkVal = 15; % this value may need revising, it works on the RGB values, not the calibrated luminance as it is about sensor noise

figure, hold on
tiledlayout(2,nIm);

for im = 1:nIm
    % load image
    folderPrefix = '~/cisc2/projects/colour_arctic/data/GOpro';
    fileFolder = fileList(randomImageIndices(im)).folder(53:end);
    fileFolder=fullfile(fileFolder);
    fileFolder(strfind(fileFolder,'\'))='/';

    [RAWmatrix,metaData] = cceRawReadGoPro([folderPrefix,fileFolder,filesep,fileList(randomImageIndices(im)).name(1:end-4),'.dng']);
    RAW_RGB = cceRawDemosaicGoPro(RAWmatrix);

    satFilter = ~any(RAW_RGB > satVal,3);
    drkFilter = ~any(RAW_RGB < drkVal,3);
    bothFilter = satFilter & drkFilter;

    [LMSmatrix,LLMmatrix,SLMmatrix,~] = cceRawRGBToLMS(RAW_RGB,metaData,1,'StockmanMacleodJohnson');

    LLMmatrix(~bothFilter) = NaN;
    SLMmatrix(~bothFilter) = NaN;

    RGB_image=ImageLMSToRGB(LMS2RGB,LMSmatrix);
    RGB_image(RGB_image<0)=0;
    RGB_image=round(255*((RGB_image./0.0079))); % where does this value come from? Jenny: probably max of the RGB images over the loop. Don't think it's important, just for plotting in a good range

    nexttile
    imshow(uint8(RGB_image))

    % 2D hist
    nexttile
    meta.figType = "grey";
    meta.edges = {linspace(0.66,0.82,40) linspace(0,2,40)};
    specLocus = false; % for some reason having this set to true this makes everything run _very_ slow. TODO investigate
    arc_2Dhist(LLMmatrix(:),SLMmatrix(:),meta,specLocus);

    % Compute ellipse params
    % I thought we had these saved but we don't have all of them
    [LogAxisRatioNCE(im), AxisRatioNormed(im), ~, ~, EllipseAngleUnnormed(im), ~, SemiMajorLength(im), SemiMinorLength(im)] = GetAxisRatio(LLMmatrix,SLMmatrix);
    center(im,:) = [mean(LLMmatrix(:),"omitnan"),mean(SLMmatrix(:),"omitnan")];
    EllipseArea(im) = pi * SemiMajorLength(im) * SemiMinorLength(im);

    % plot ellipse
    drawellipse(gca,'SemiAxes',[SemiMajorLength(im),SemiMinorLength(im)],...
    'Center',center(im,:),...
    'RotationAngle',360-EllipseAngleUnnormed(im));

    xlim([min(meta.edges{1}),max(meta.edges{1})])
    ylim([min(meta.edges{2}),max(meta.edges{2})])
end


% % cross check

[fileList(randomImageIndices).NCE]
LogAxisRatioNCE

[fileList(randomImageIndices).AxisRatioNormed]
AxisRatioNormed

[fileList(randomImageIndices).EllipseAngle]
EllipseAngleUnnormed

%% Nanolambda data

%
% Use code in preProcessNL.m
%

%% Hyperspectral

clear, clc, close all

repoHomeDir = ['..',filesep,'..',filesep,'..',filesep];
addpath(repoHomeDir);
addpath([repoHomeDir,'imageanalysis',filesep]);
addpath([repoHomeDir,'hyperspectralAnalysis',filesep]);

LMSimDir = '~/cisc1/projects/colour_arctic/hyperspectralOutputs';
d = dir([LMSimDir,filesep,'*.mat']);

rng(1) % if we're randomly selecting a subset, make it reproducible
nIm = 6;
figure, hold on
tiledlayout(2,nIm);

for i = randi(size(d,1),[1,nIm])
    disp(i)

    t = load([d(i).folder,filesep,d(i).name],'LLMImage','SLMImage');

    [LogAxisRatioNCE(i), AxisRatioNormed(i), ~, ~, EllipseAngleUnnormed(i), ~, SemiMajorLength(i), SemiMinorLength(i)] = ...
        GetAxisRatio(t.LLMImage,t.SLMImage);
    EllipseArea(i) = pi * SemiMajorLength(i) * SemiMinorLength(i);
    center(i,:) = [mean(t.LLMImage(:),"omitnan"),mean(t.SLMImage(:),"omitnan")];

    nexttile
    imshow(imread([LMSimDir,filesep,d(i).name(1:end-10),'.png']))

    nexttile
    meta.figType = "grey";
    meta.edges = {linspace(0.66,0.82,40) linspace(0,2,40)};
    specLocus = false; % for some reason having this set to true this makes everything run _very_ slow. TODO investigate
    arc_2Dhist(t.LLMImage(:),t.SLMImage(:),meta,specLocus);
    drawellipse(gca,'SemiAxes',[SemiMajorLength(i),SemiMinorLength(i)],...
        'Center',center(i,:),...
        'RotationAngle',360-EllipseAngleUnnormed(i),...
        'FaceAlpha',0);

end



