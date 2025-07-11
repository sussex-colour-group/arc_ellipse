% visualise ellipse fit

% plots 2Dhist and ellipse (and image, in the case of GoPro and
% hyperspectral image)

% TODO Pull in (or reference) where this is done elsewhere
% (below is just NL for now)
% GoPro happens in 

%% Nanolambda data
% Pick some random hours and plot ellipse and 2D hist

% TODO Fix broken refs
% data = load(...) % etc...

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