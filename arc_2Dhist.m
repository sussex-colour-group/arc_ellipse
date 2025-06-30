function arc_2Dhist(x,y,meta,specLocus)

if strcmp(meta.figType, "colour") % use hues per bin

    % Modified from `PlotMacBHistogram.m`
    LLMColour = repmat(movmean(meta.edges{1,1},2,"Endpoints","discard"),...
        length(movmean(meta.edges{1,2},2,"Endpoints","discard")),1);
    SLMColour = repmat(movmean(meta.edges{1,2},2,"Endpoints","discard").',1,...
        length(movmean(meta.edges{1,1},2,"Endpoints","discard")));

    RGB = SelectRGBs('NSDFMRI');
    LMS = SelectConeFundamentals('StockmanMacleodJohnson');
    [~,LMS2RGB] = RGBToLMS(LMS,RGB,0);
    powernorm = 0.5;

end

if strcmp(meta.figType, "colour")

    histmatrix = histcounts2(x,y,...
        'XBinEdges',meta.edges{1,1},'YBinEdges',meta.edges{1,2})';
    LandMColour = 0.01.*((histmatrix.^powernorm)./(max(max((histmatrix.^powernorm)))));
    LMS = MacBToLMS(LLMColour,SLMColour,LandMColour);
    RGBmatrix = ImageLMSToRGB(LMS2RGB,LMS);

    image(RGBmatrix,...
        'Xdata',movmean(meta.edges{1,1},2,"Endpoints","discard"),...
        'Ydata',movmean(meta.edges{1,2},2,"Endpoints","discard"));

else % grayscale
    histogram2(x,y,...
        'XBinedges',meta.edges{1,1},'YBinedges',meta.edges{1,2},...
        'DisplayStyle','tile','ShowEmptyBins','on','EdgeColor','none');
    colormap('gray')
end

% colorbar
axis tight square
set(gca,'TickDir','out')
set(gca,'YDir','normal')

if exist("specLocus","var") && specLocus == true

    try
        % Following code inherited from:
        % arc_PsychophysicsAnalysis/whiteSetting.m
        coneFundamentals = SelectConeFundamentals('StockmanMacleodJohnson'); % 10-degree % From `arc_config.m`
        a(1,:,:) =  coneFundamentals; % hack because LMSToMacB needs a 3D matrix
        [LLMmatrix,SLMmatrix] = LMSToMacB(a);

        % Following code inherited from: 
        % PsychToolbox/PsychColorimetric/DrawChromaticity.m
        load T_xyz1931 T_xyz1931  % CMF: 1931 2deg
        sRGB_SL = XYZToSRGBPrimary(T_xyz1931); % sRGB Spectral Locus
        sRGB_SL(sRGB_SL>1) = 1; %Threshold values to between 0 and 1
        sRGB_SL(sRGB_SL<0) = 0;
        sRGB_SL = sRGB_SL(:,21:421); % match wavelength sampling limits

        hold on
        for i = 1:401
            plot(LLMmatrix(i),SLMmatrix(i),...
                '-o','MarkerFaceColor',sRGB_SL(:,i),'MarkerEdgeColor',sRGB_SL(:,i),...
                'MarkerSize',3);
        end

    catch
        warning('Plotting the spectral locus did not work - perhaps you do not have PsychToolbox installed?')
    end
end

end