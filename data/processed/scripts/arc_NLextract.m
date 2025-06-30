function arc_NLextract(dataDir,saveDir,paths)

% test paths
for path = paths
    if exist([dataDir, filesep, path{1}], 'dir')
    else
        warning(['folder path error: ',[dataDir, filesep, path{1}]])
    end
end

%%

for ds = 1:length(paths) % ds for dataset

    % go through each folder
    folderList = dir([dataDir, filesep, paths{ds}]);
    dirFlags = [folderList.isdir] & ~strcmp({folderList.name},'.') & ~strcmp({folderList.name},'..');
    folderList = folderList(dirFlags);

    for f = 1:length(folderList)
        try
            disp(['processing: ',dataDir,filesep,paths{ds},filesep,folderList(f).name]);

            %find csv files
            csvList = dir([dataDir,filesep,paths{ds},filesep,folderList(f).name,filesep,'*.csv']);
            if isempty(csvList)
                warning('No data')
                continue
            end


            allNLdata = [];
            allSpecArray = [];
            allNLXYZ = [];
            allNLxy = [];
            allNLCCT = [];
            allsatData = [];

            % concatenate separate csv files
            for c = 1:length(csvList)
                csvFile = csvList(c).name;
                saturationWarning = false;
                dontSort = 0;
                [NLdata,specArray,NLXYZ,NLxy,NLCCT,satData,indOrder] = ...
                    NLextract([dataDir,filesep,paths{ds},filesep,folderList(f).name,filesep,csvFile],...
                    dontSort,saturationWarning);
                allNLdata = [allNLdata;NLdata];
                allSpecArray = [allSpecArray;specArray(2:end,:)];
                allNLXYZ = [allNLXYZ;NLXYZ];
                allNLxy = [allNLxy;NLxy];
                allNLCCT = [allNLCCT;NLCCT];
                allsatData = [allsatData;satData];
            end % csv loop

            % get unique entries (based on time)
            [~,allIndex] = unique(allNLdata.when);

            % then filter all the outputs by that index
            allNLdata           = allNLdata(allIndex,:);
            allSpecArray        = allSpecArray(allIndex,:);
            allNLXYZ            = allNLXYZ(allIndex,:);
            allNLxy             = allNLxy(allIndex,:);
            allNLCCT            = allNLCCT(allIndex,:);

            % put the wavelengths back at the top of the spec array
            allSpecArray = [specArray(1,:);allSpecArray];

            % do the same for satData, if there is any
            if ~isempty(satData)
                [~,satIndex] = unique(allsatData.when);
                allsatData  = allsatData(satIndex,:);
            end

            % save this output as a .mat file
            if ~exist([saveDir,filesep,paths{ds}],'dir')
                mkdir([saveDir,filesep,paths{ds}])
            end
            save([saveDir,filesep,paths{ds},filesep,folderList(f).name,'.mat'],...
                'allNLdata','allSpecArray','allNLXYZ','allNLxy','allNLCCT','allsatData')

            % save([dataDir,filesep,paths{ds},filesep,folderList(f).name,'.mat'],...
            %     'allNLdata','allSpecArray','allNLXYZ','allNLxy','allNLCCT','allsatData')

        catch e % https://uk.mathworks.com/matlabcentral/answers/325475-display-error-message-and-execute-catch#answer_255132
            disp(['There was an error!',newline,...
                'The identifier was: ',e.identifier,newline,...
                'The message was: ',e.message]);
        end

        %     % plot to see how much data was collected
        %     subplot(length(folderList),1,f)
        %     dayData = allNLdata.when;
        %     plot(dayData,~isnan(allNLdata.intT),'xk')
        %     xlim([min(dayData) max(dayData)])
        %     yticks([])
        %     ylabel(folderList(f).name)
        %     xticks([min(dayData) max(dayData)]);
        %     sgtitle('Tromso')

    end
end